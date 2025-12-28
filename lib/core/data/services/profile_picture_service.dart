import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/constants/constants.dart';
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
    File file, {
    void Function(double progress)? onProgress,
    int retryAttempts = 5,
    int retryDelayMs = 500,
  }) async {
    final ref = FirebaseStorage.instanceFor(
      app: Firebase.app(KConst.appName),
    ).ref('users/$uid/profile.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = ref.putFile(file, metadata);

    final sub = uploadTask.snapshotEvents.listen((snap) {
      final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
      final prog = snap.bytesTransferred / total;
      if (onProgress != null) onProgress(prog);
    });

    try {
      final TaskSnapshot snap = await uploadTask;
      if (snap.state != TaskState.success) {
        throw Exception('Upload failed');
      }

      // Retry getDownloadURL until available
      String url;
      DatabaseException? lastEx;
      for (var i = 0; i < retryAttempts; i++) {
        try {
          url = await ref.getDownloadURL();
          // persist to Firestore and update notifier
          await setProfileUrl(uid, url);
          return url;
        } on DatabaseException catch (e) {
          lastEx = e;
          await Future.delayed(Duration(milliseconds: retryDelayMs));
        }
      }
      throw lastEx ?? Exception('Unknown error getting download URL');
    } finally {
      await sub.cancel();
    }
  }
}
