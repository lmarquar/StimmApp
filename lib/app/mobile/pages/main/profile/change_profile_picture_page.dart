import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

class ChangeProfilePicturePage extends StatefulWidget {
  const ChangeProfilePicturePage({super.key});

  @override
  State<ChangeProfilePicturePage> createState() =>
      _ChangeProfilePicturePageState();
}

class _ChangeProfilePicturePageState extends State<ChangeProfilePicturePage> {
  File? _imageFile;
  bool _uploading = false;
  double _progress = 0.0;
  final ImagePicker _picker = ImagePicker();

  // subscription so we can cancel listening when disposed
  StreamSubscription<TaskSnapshot>? _uploadSub;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  Future<void> _removeImage() async {
    setState(() => _imageFile = null);
  }

  Future<void> _uploadAndSave() async {
    final l10n = AppLocalizations.of(context)!;
    if (_imageFile == null) {
      showErrorSnackBar(l10n.noImageSelected);
      return;
    }

    if (!await _imageFile!.exists()) {
      showErrorSnackBar('Selected file does not exist');
      return;
    }

    final user = authService.value.currentUser;
    if (user == null) {
      showErrorSnackBar(l10n.pleaseSignInFirst);
      return;
    }

    final uid = user.uid;
    final storageRef = FirebaseStorage.instance.ref('users/$uid/profile.jpg');

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    // Attach contentType metadata to help Storage identify the file quickly.
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = storageRef.putFile(_imageFile!, metadata);

    // listen and throttle progress updates
    _uploadSub = uploadTask.snapshotEvents.listen(
      (snap) {
        final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
        final prog = snap.bytesTransferred / total;
        if (!mounted) return;
        if ((prog - _progress).abs() > 0.01) {
          setState(() {
            _progress = prog;
          });
        }
      },
      onError: (e) {
        debugPrint('[ChangeProfilePicture] upload snapshot error: $e');
        // don't show snackbar here to avoid spamming; final catch below will handle.
      },
    );

    try {
      // Await the task and inspect final snapshot state
      final TaskSnapshot taskSnapshot = await uploadTask;
      // cancel listener after upload completes
      await _uploadSub?.cancel();
      _uploadSub = null;

      if (taskSnapshot.state == TaskState.canceled) {
        debugPrint('[ChangeProfilePicture] upload was cancelled by Storage');
        if (mounted) showErrorSnackBar('Upload cancelled');
        return;
      }
      if (taskSnapshot.state != TaskState.success) {
        debugPrint(
          '[ChangeProfilePicture] upload finished with state: ${taskSnapshot.state}',
        );
        if (mounted) {
          showErrorSnackBar('Upload failed (state: ${taskSnapshot.state})');
        }
        return;
      }

      // Sometimes getDownloadURL can fail with object-not-found immediately after upload.
      // Retry a few times with a short delay before giving up.
      final url = await _getDownloadUrlWithRetry(
        storageRef,
        attempts: 5,
        delayMs: 500,
      );

      // update auth profile and firestore safely
      try {
        await user.updatePhotoURL(url);
        await user.reload();
      } catch (e) {
        debugPrint('[ChangeProfilePicture] error updating user photoURL: $e');
      }

      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'profilePictureUrl': url,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[ChangeProfilePicture] error writing to firestore: $e');
      }

      if (!mounted) return;
      showSuccessSnackBar(l10n.profilePictureUpdated);
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      debugPrint(
        '[ChangeProfilePicture] FirebaseException: ${e.code} ${e.message}',
      );
      final msg = e.message ?? 'Failed to upload image: ${e.code}';
      if (e.code == 'object-not-found') {
        debugPrint(
          '[ChangeProfilePicture] object-not-found after upload; storage rules or timing issue.',
        );
        if (mounted) {
          showErrorSnackBar(
            'Upload incomplete: file not found in storage yet. Try again shortly.',
          );
        }
      } else {
        if (mounted) showErrorSnackBar(msg);
      }
    } catch (e, st) {
      debugPrint('[ChangeProfilePicture] upload failed: $e\n$st');
      if (mounted) showErrorSnackBar('Failed to upload image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
      await _uploadSub?.cancel();
      _uploadSub = null;
    }
  }

  // Helper: retry getDownloadURL a few times with delay
  Future<String> _getDownloadUrlWithRetry(
    Reference ref, {
    int attempts = 3,
    int delayMs = 300,
  }) async {
    FirebaseException? lastEx;
    for (var i = 0; i < attempts; i++) {
      try {
        final url = await ref.getDownloadURL();
        return url;
      } on FirebaseException catch (e) {
        lastEx = e;
        debugPrint(
          '[ChangeProfilePicture] getDownloadURL attempt ${i + 1} failed: ${e.code} ${e.message}',
        );
        // if object-not-found, wait and retry; other errors probably won't succeed
        if (i < attempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }
    throw lastEx ??
        FirebaseException(
          plugin: 'firebase_storage',
          message: 'Unknown error getting download URL',
        );
  }

  @override
  void dispose() {
    _uploadSub?.cancel();
    _uploadSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUrl = authService.value.currentUser?.photoURL;

    final preview = _imageFile != null
        ? Image.file(_imageFile!, fit: BoxFit.cover)
        : (currentUrl != null
              ? Image.network(currentUrl, fit: BoxFit.cover)
              : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: ClipOval(
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child:
                            preview ??
                            Center(
                              child: Text(
                                (authService.value.currentUser?.displayName ??
                                            '')
                                        .isNotEmpty
                                    ? authService
                                          .value
                                          .currentUser!
                                          .displayName![0]
                                          .toUpperCase()
                                    : '?',
                                style: AppTextStyles.xxlBold,
                              ),
                            ),
                      ),
                    ),
                  ),
                  if (_uploading)
                    SizedBox(
                      width: 128,
                      height: 128,
                      child: CircularProgressIndicator(value: _progress),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: Text(l10n.select),
                ),
                ElevatedButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.select),
                ),
                TextButton(
                  onPressed: _uploading ? null : _removeImage,
                  child: Text(l10n.cancel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _uploading ? null : _uploadAndSave,
              child: Text(l10n.confirm),
            ),
            const SizedBox(height: 12),
            if (_imageFile != null)
              Text(
                l10n.enterDescription,
                style: AppTextStyles.m.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
