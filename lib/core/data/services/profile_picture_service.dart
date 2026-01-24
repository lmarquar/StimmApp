import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

class ProfilePictureService {
  ProfilePictureService._(this._firestoreService, [FirebaseStorage? storage])
    : _storage = storage ?? FirebaseStorage.instance;

  static final ProfilePictureService instance = ProfilePictureService._(
    locator.databaseService,
  );

  /// Factory for tests to provide a mock storage.
  @visibleForTesting
  static ProfilePictureService createForTest({
    required DatabaseService databaseService,
    required FirebaseStorage storage,
  }) {
    return ProfilePictureService._(databaseService, storage);
  }

  final DatabaseService _firestoreService;
  final FirebaseStorage _storage;

  // Notifier that UI can listen to
  final ValueNotifier<String?> profileUrlNotifier = ValueNotifier<String?>(
    null,
  );

  Future<String?> loadProfileUrl(String uid) async {
    final doc = await _firestoreService.getDoc(
      _firestoreService.docRef(
        'users/$uid',
        fromFirestore: (snap, _) => snap.data(),
        toFirestore: (data, _) => data!,
      ),
    );
    final url = doc?['profilePictureUrl'] as String?;
    profileUrlNotifier.value = url;
    return url;
  }

  Future<void> setProfileUrl(String uid, String? url) async {
    if (url == null) return;
    await _firestoreService.upsert(
      _firestoreService.docRef(
        'users/$uid',
        fromFirestore: (snap, _) => snap.data(),
        toFirestore: (data, _) => data!,
      ),
      {'profilePictureUrl': url},
    );
    profileUrlNotifier.value = url;
  }

  // Uploads file, reports progress via onProgress and returns the download URL.
  Future<String> uploadProfilePicture(
    String uid,
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref('users/$uid/profile.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = kIsWeb
        ? ref.putData(await file.readAsBytes(), metadata)
        : ref.putFile(File(file.path), metadata);

    final sub = uploadTask.snapshotEvents.listen(
      (snap) {
        final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
        final prog = snap.bytesTransferred / total;
        if (onProgress != null) onProgress(prog);
      },
      onError: (e) {
        debugPrint('Upload task error: $e');
      },
    );

    try {
      final TaskSnapshot snap = await uploadTask;
      if (snap.state != TaskState.success) {
        throw Exception('Upload failed');
      }

      final String url = await ref.getDownloadURL();
      await setProfileUrl(uid, url);
      return url;
    } finally {
      await sub.cancel();
    }
  }

  Future<void> deleteProfilePicture(String uid) async {
    try {
      final ref = _storage.ref('users/$uid/profile.jpg');
      await ref.delete();
    } catch (e) {
      // If the file doesn't exist, we don't care
      debugPrint('Error deleting profile picture: $e');
    }
    profileUrlNotifier.value = null;
  }

  Future<String> uploadIdImage(
    String uid,
    XFile file,
    bool isFront, {
    void Function(double progress)? onProgress,
  }) async {
    final fileName = isFront ? 'id_front.jpg' : 'id_back.jpg';
    final ref = _storage.ref('users/$uid/$fileName');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = kIsWeb
        ? ref.putData(await file.readAsBytes(), metadata)
        : ref.putFile(File(file.path), metadata);

    final sub = uploadTask.snapshotEvents.listen(
      (snap) {
        final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
        final prog = snap.bytesTransferred / total;
        if (onProgress != null) onProgress(prog);
      },
      onError: (e) {
        debugPrint('Upload task error: $e');
      },
    );

    try {
      final TaskSnapshot snap = await uploadTask;
      if (snap.state != TaskState.success) {
        throw Exception('Upload failed');
      }

      return await ref.getDownloadURL();
    } finally {
      await sub.cancel();
    }
  }
}
