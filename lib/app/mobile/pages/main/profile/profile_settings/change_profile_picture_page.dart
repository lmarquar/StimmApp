import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stimmapp/core/constants/constants.dart';

// Only imported on non-web platforms
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show File;

import 'package:stimmapp/core/data/services/auth_service.dart';

class ChangeProfilePicturePage extends StatefulWidget {
  const ChangeProfilePicturePage({super.key});

  @override
  State<ChangeProfilePicturePage> createState() =>
      _ChangeProfilePicturePageState();
}

class _ChangeProfilePicturePageState extends State<ChangeProfilePicturePage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    if (kIsWeb) {
      _webImageBytes = await image.readAsBytes();
    }

    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final user = authService.value.currentUser;
      if (user == null) throw Exception('User not logged in');

      final ref = FirebaseStorage.instanceFor(
        app: Firebase.app(KConst.appName),
      ).ref('users/${user.uid}/profile.jpg');

      if (kIsWeb) {
        await ref.putData(_webImageBytes!);
      } else {
        await ref.putFile(File(_pickedImage!.path));
      }

      final downloadUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage == null) {
      return const CircleAvatar(
        radius: 60,
        child: Icon(Icons.person, size: 60),
      );
    }

    if (kIsWeb) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(_webImageBytes!),
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundImage: FileImage(File(_pickedImage!.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Profile Picture')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Choose Image'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isUploading || _pickedImage == null
                  ? null
                  : _uploadImage,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
