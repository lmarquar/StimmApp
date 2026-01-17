import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:universal_io/io.dart';

/// Interface for storage interactions (profile pictures and similar).
abstract class IStorageService {
  /// Uploads a profile picture file for [uid], returns the download URL.
  Future<String> uploadProfilePicture(String uid, File file);

  /// Deletes the profile picture for [uid].
  Future<void> deleteProfilePicture(String uid);

  /// Gets the download URL for [uid]'s profile picture, or null if not found.
  Future<String?> getProfilePictureUrl(String uid);

  /// Uploads a title image for a poll and returns the download URL.
  Future<String> uploadPollTitleImage(String pollId, File file);

  /// Deletes a poll title image.
  Future<void> deletePollTitleImage(String pollId);

  /// Gets poll title image URL or null.
  Future<String?> getPollTitleImageUrl(String pollId);

  /// Uploads a title image for a petition and returns the download URL.
  Future<String> uploadPetitionTitleImage(String petitionId, File file);

  /// Deletes a petition title image.
  Future<void> deletePetitionTitleImage(String petitionId);

  /// Gets petition title image URL or null.
  Future<String?> getPetitionTitleImageUrl(String petitionId);

  /// Uploads an arbitrary file into the authenticated user's storage area
  /// under a relative path (e.g. 'petition_images/name>.jpg') and returns the download URL.
  Future<String> uploadUserFile(String uid, String relativePath, dynamic file);

  /// Uploads raw bytes into users/{uid}/{relativePath} and returns the download URL.
  Future<String> uploadUserBytes(
    String uid,
    String relativePath,
    Uint8List data, {
    String? contentType,
  });
}

/// Concrete Firebase Storage implementation.
class StorageService implements IStorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  String _profilePath(String uid) => 'profile_pictures/$uid.jpg';
  String _pollTitlePath(String pollId) => 'poll_title_images/$pollId.jpg';
  String _petitionTitlePath(String petitionId) =>
      'petition_title_images/$petitionId.jpg';

  @override
  Future<String> uploadProfilePicture(String uid, File file) async {
    try {
      final ref = _storage.ref().child(_profilePath(uid));
      final task = await ref.putFile(file);
      // ensure upload completed
      await task.ref.getDownloadURL();
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e);
    }
  }

  @override
  Future<void> deleteProfilePicture(String uid) async {
    try {
      final ref = _storage.ref().child(_profilePath(uid));
      await ref.delete();
    } on FirebaseException catch (e) {
      // If object not found, treat as no-op.
      if (e.code == 'object-not-found' || e.code == '404') return;
      throw StorageException(e);
    }
  }

  @override
  Future<String?> getProfilePictureUrl(String uid) async {
    try {
      final ref = _storage.ref().child(_profilePath(uid));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == '404') return null;
      throw StorageException(e);
    }
  }

  @override
  Future<String> uploadPollTitleImage(String pollId, File file) async {
    try {
      final ref = _storage.ref().child(_pollTitlePath(pollId));
      final taskSnapshot = await ref.putFile(file);
      await taskSnapshot.ref.getDownloadURL();
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e);
    }
  }

  @override
  Future<void> deletePollTitleImage(String pollId) async {
    try {
      final ref = _storage.ref().child(_pollTitlePath(pollId));
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == '404') return;
      throw StorageException(e);
    }
  }

  @override
  Future<String?> getPollTitleImageUrl(String pollId) async {
    try {
      final ref = _storage.ref().child(_pollTitlePath(pollId));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == '404') return null;
      throw StorageException(e);
    }
  }

  @override
  Future<String> uploadPetitionTitleImage(String petitionId, File file) async {
    try {
      final ref = _storage.ref().child(_petitionTitlePath(petitionId));
      final taskSnapshot = await ref.putFile(file);
      await taskSnapshot.ref.getDownloadURL();
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e);
    }
  }

  @override
  Future<void> deletePetitionTitleImage(String petitionId) async {
    try {
      final ref = _storage.ref().child(_petitionTitlePath(petitionId));
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == '404') return;
      throw StorageException(e);
    }
  }

  @override
  Future<String?> getPetitionTitleImageUrl(String petitionId) async {
    try {
      final ref = _storage.ref().child(_petitionTitlePath(petitionId));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == '404') return null;
      throw StorageException(e);
    }
  }

  /// Uploads a file into users/{uid}/{relativePath} and returns a download URL.
  @override
  Future<String> uploadUserFile(
    String uid,
    String relativePath,
    dynamic file,
  ) async {
    try {
      final ref = _storage.ref().child('users/$uid/$relativePath');
      // Keep existing putFile behavior for platforms where File is available
      final taskSnapshot = await ref.putFile(file);
      await taskSnapshot.ref.getDownloadURL();
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e);
    }
  }

  /// Uploads raw bytes into users/{uid}/{relativePath} and returns a download URL.
  @override
  Future<String> uploadUserBytes(
    String uid,
    String relativePath,
    Uint8List data, {
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child('users/$uid/$relativePath');
      final metadata = SettableMetadata(
        contentType: contentType ?? 'application/octet-stream',
      );
      final taskSnapshot = await ref.putData(data, metadata);
      await taskSnapshot.ref.getDownloadURL();
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e);
    }
  }
}

class StorageException implements Exception {
  final FirebaseException storageException;
  StorageException(this.storageException);

  String? get message => storageException.message;
  String get code => storageException.code;

  @override
  String toString() => 'StorageException (code: $code): $message';
}
