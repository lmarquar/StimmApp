import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class ChangeProfilePicturePage extends StatefulWidget {
  const ChangeProfilePicturePage({super.key});

  @override
  State<ChangeProfilePicturePage> createState() =>
      _ChangeProfilePicturePageState();
}

class _ChangeProfilePicturePageState extends State<ChangeProfilePicturePage> {
  XFile? _imageFile;
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
    setState(() => _imageFile = picked);
  }

  Future<void> _removeImage() async {
    setState(() => _imageFile = null);
  }

  Future<void> _uploadAndSave() async {
    if (_imageFile == null) {
      showErrorSnackBar(context.l10n.noImageSelected);
      return;
    }

    final user = authService.currentUser;
    if (user == null) {
      showErrorSnackBar(context.l10n.pleaseSignInFirst);
      return;
    }

    final uid = user.uid;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final url = await ProfilePictureService.instance.uploadProfilePicture(
        uid,
        _imageFile!,
        onProgress: (p) {
          if (!mounted) return;
          // throttle UI updates
          if ((p - _progress).abs() > 0.01) {
            setState(() => _progress = p);
          }
        },
      );
      try {
        await user.updatePhotoURL(url);
        await user.reload();
      } catch (e) {
        debugPrint('[ChangeProfilePicture] error updating user photoURL: $e');
      }

      if (!mounted) return;
      showSuccessSnackBar(context.l10n.profilePictureUpdated);
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('[ChangeProfilePicture] upload failed: $e\n$st');
      if (mounted) {
        showErrorSnackBar('${context.l10n.failedToUploadImage}$e');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _uploadSub?.cancel();
    _uploadSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = authService.currentUser?.photoURL;

    Widget? preview;
    if (_imageFile != null) {
      if (kIsWeb) {
        preview = Image.network(_imageFile!.path, fit: BoxFit.cover);
      } else {
        preview = Image.file(File(_imageFile!.path), fit: BoxFit.cover);
      }
    } else if (currentUrl != null) {
      preview = Image.network(currentUrl, fit: BoxFit.cover);
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
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
                        child: preview ??
                            Center(
                              child: Text(
                                (authService.currentUser?.displayName ?? '')
                                        .isNotEmpty
                                    ? authService.currentUser!.displayName![0]
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
                  onPressed:
                      _uploading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: Text(context.l10n.selectFromGallery),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _uploading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(context.l10n.selectFromCamera),
                ),
                TextButton(
                  onPressed: _uploading ? null : _removeImage,
                  child: Text(context.l10n.remove),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _uploading ? null : _uploadAndSave,
              child: Text(context.l10n.confirm),
            ),
            const SizedBox(height: 12),
            if (_imageFile != null)
              Text(
                context.l10n.imagePreviewDescription,
                style: AppTextStyles.m.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
