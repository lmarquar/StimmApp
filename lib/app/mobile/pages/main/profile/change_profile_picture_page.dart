import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
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
      showSuccessSnackBar(l10n.profilePictureUpdated);
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('[ChangeProfilePicture] upload failed: $e\n$st');
      if (mounted) showErrorSnackBar('Failed to upload image: $e');
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
