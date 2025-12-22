import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ProfilePictureService {
  ProfilePictureService._();
  static final ProfilePictureService instance = ProfilePictureService._();

  // Notifier that UI can listen to
  final ValueNotifier<String?> profileUrlNotifier = ValueNotifier<String?>(
    null,
  );

  Future<String?> loadProfileUrl(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final url = doc.data()?['profilePictureUrl'] as String?;
    profileUrlNotifier.value = url;
    return url;
  }

  Future<void> setProfileUrl(String uid, String? url) async {
    if (url == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profilePictureUrl': url,
    }, SetOptions(merge: true));
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
    final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
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
        throw FirebaseException(
          plugin: 'firebase_storage',
          message: 'Upload failed (state: ${snap.state})',
        );
      }

      // Retry getDownloadURL until available
      String url;
      FirebaseException? lastEx;
      for (var i = 0; i < retryAttempts; i++) {
        try {
          url = await ref.getDownloadURL();
          // persist to Firestore and update notifier
          await setProfileUrl(uid, url);
          return url;
        } on FirebaseException catch (e) {
          lastEx = e;
          await Future.delayed(Duration(milliseconds: retryDelayMs));
        }
      }
      throw lastEx ??
          FirebaseException(
            plugin: 'firebase_storage',
            message: 'Unknown error getting download URL',
          );
    } finally {
      await sub.cancel();
    }
  }
}
