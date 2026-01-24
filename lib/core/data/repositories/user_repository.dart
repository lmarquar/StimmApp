import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/constants/database_collections.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

import 'petition_repository.dart';
import 'poll_repository.dart';

class UserRepository {
  UserRepository(this._fs);

  final DatabaseService _fs;

  static UserRepository create() => UserRepository(locator.databaseService);

  static Future<UserProfile?> currentUser() {
    final uid = locator.authService.currentUser?.uid;
    if (uid == null) {
      return Future.value(null);
    }
    return create().getById(uid);
  }

  CollectionReference<UserProfile> _col() {
    return _fs.colRef<UserProfile>(
      DatabaseCollections.users,
      fromFirestore: (snap, _) =>
          UserProfile.fromJson(snap.data() as Map<String, dynamic>, snap.id),
      toFirestore: (model, _) => model.toJson(),
    );
  }

  DocumentReference<UserProfile> _doc(String uid) {
    return _col().doc(uid);
  }

  Future<UserProfile?> getById(String uid) async {
    return _fs.getDoc(_doc(uid));
  }

  Future<void> upsert(UserProfile profile) async {
    await _fs.upsert(
      _doc(profile.uid),
      profile.copyWith(updatedAt: DateTime.now()),
    );
  }

  Future<void> delete(String uid) async {
    // Use repository helpers to remove user activity and close created items.
    final pollRepo = PollRepository.create();
    final petitionRepo = PetitionRepository.create();

    // Remove votes and signatures (decrements counts and removes subdocs)
    await pollRepo.removeVotesByUser(uid);
    await petitionRepo.removeSignaturesByUser(uid);

    // Delete the user profile document
    await _fs.delete(_doc(uid));

    // Delete profile picture from storage
    try {
      await locator.storageService.deleteProfilePicture(uid);
    } catch (e) {
      // In tests where Firebase Storage might not be initialized, or if it fails,
      // we log but don't fail the whole user deletion.
      print('Error deleting profile picture: $e');
    }

    // Close polls and petitions created by this user
    await pollRepo.closePollsCreatedByUser(uid);
    await petitionRepo.closePetitionsCreatedByUser(uid);
  }

  Stream<UserProfile?> watchById(String uid) {
    return _fs.watchDoc(_doc(uid));
  }

  Stream<List<UserProfile>> watchAll({int? limit}) {
    return _fs.watchCol(_col(), limit: limit);
  }
}
