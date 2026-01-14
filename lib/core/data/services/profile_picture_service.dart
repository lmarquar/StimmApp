import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';

class ProfilePictureService {
  ProfilePictureService._(this._firestoreService);
  static final ProfilePictureService instance = ProfilePictureService._(
    locator.databaseService,
  );

  final DatabaseService _firestoreService;

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
    int retryAttempts = 5,
    int retryDelayMs = 500,
  }) async {
    final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = kIsWeb
        ? ref.putData(await file.readAsBytes(), metadata)
        : ref.putFile(File(file.path), metadata);

    final sub = uploadTask.snapshotEvents.listen((snap) {
      final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
      final prog = snap.bytesTransferred / total;
      if (onProgress != null) onProgress(prog);
    }, onError: (e) {
      debugPrint('Upload task error: $e');
      if (e is FirebaseException) {
        debugPrint('FirebaseStorage error code: ${e.code}, message: ${e.message}');
      }
    });

    try {
      final TaskSnapshot snap = await uploadTask;
      if (snap.state != TaskState.success) {
        throw Exception('Upload failed');
      }

      // Retry getDownloadURL and setProfileUrl until successful
      String url;
      dynamic lastEx;
      for (var i = 1; i <= retryAttempts; i++) {
        try {
          debugPrint('getDownloadURL attempt $i for UID: $uid');
          try {
            url = await ref.getDownloadURL();
          } catch (e) {
            debugPrint('getDownloadURL failed: $e');
            rethrow;
          }
          
          debugPrint('setProfileUrl attempt $i for UID: $uid');
          try {
            await setProfileUrl(uid, url);
          } catch (e) {
            debugPrint('setProfileUrl failed: $e');
            rethrow;
          }
          return url;
        } catch (e) {
          lastEx = e;
          debugPrint('Operation failed during attempt $i: $e');
          if (e is FirebaseException) {
            debugPrint('Firebase error code: ${e.code}, message: ${e.message}');
          }
          
          // Exponential-ish backoff
          await Future.delayed(Duration(milliseconds: retryDelayMs * i * i));
        }
      }
      throw lastEx ?? Exception('Unknown error getting download URL');
    } finally {
      await sub.cancel();
    }
  }

  Future<void> deleteProfilePicture(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
      await ref.delete();
    } catch (e) {
      // If the file doesn't exist, we don't care
      debugPrint('Error deleting profile picture: $e');
    }
    profileUrlNotifier.value = null;
  }
}
