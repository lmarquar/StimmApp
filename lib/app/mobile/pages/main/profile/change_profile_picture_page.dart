import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
    });
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
    final user = authService.value.currentUser;
    if (user == null) {
      showErrorSnackBar(l10n.pleaseSignInFirst);
      return;
    }

    final uid = user.uid;
    final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    final uploadTask = ref.putFile(_imageFile!);

    uploadTask.snapshotEvents.listen(
      (snapshot) {
        final prog =
            snapshot.bytesTransferred /
            (snapshot.totalBytes == 0 ? 1 : snapshot.totalBytes);
        setState(() {
          _progress = prog;
        });
      },
      onError: (e) {
        showErrorSnackBar('Upload failed');
      },
    );

    try {
      await uploadTask;
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      await user.reload();
      // show success
      showSuccessSnackBar(l10n.profilePictureUpdated);
      Navigator.of(context).pop(); // close page
    } catch (e) {
      showErrorSnackBar('Failed to upload image');
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUrl = authService.value.currentUser?.photoURL;
    final display = _imageFile != null
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
                    ).colorScheme.surfaceVariant,
                    child: ClipOval(
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child:
                            display ??
                            Center(
                              child: Text(
                                (authService.value.currentUser?.displayName ??
                                            '')
                                        .isNotEmpty
                                    ? (authService
                                          .value
                                          .currentUser!
                                          .displayName![0]
                                          .toUpperCase())
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
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 6,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: Text(l10n.select),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    l10n.changeLanguage,
                  ), // reuse existing key "changeLanguage" for "Take photo" if needed; you can adjust
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: _removeImage, child: Text(l10n.cancel)),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _uploading ? null : _uploadAndSave,
                  child: Text(l10n.confirm),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              Text(
                l10n.enterDescription,
                style: AppTextStyles.m.copyWith(color: Colors.grey),
              ), // optional hint
          ],
        ),
      ),
    );
  }
}
