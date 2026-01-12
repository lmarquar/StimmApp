import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/constants/database_collections.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

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
    final db = _fs.instance;
    final userRef = db.collection('users').doc(uid);

    // 1. Get user's activity (voted polls and signed petitions)
    // Based on PollRepository.vote and PetitionRepository.sign,
    // these are stored in subcollections of the user document.
    final votedPollsSnap = await userRef.collection('votedPolls').get();
    final signedPetitionsSnap = await userRef.collection('signedPetitions').get();

    await db.runTransaction((txn) async {
      // 2. Decrement poll counts and remove vote records
      for (final doc in votedPollsSnap.docs) {
        final pollId = doc.id;
        final optionId = doc.data()['optionId'] as String?;
        if (optionId != null) {
          final pollRef = db.collection('polls').doc(pollId);
          txn.update(pollRef, {'votes.$optionId': FieldValue.increment(-1)});
          txn.delete(pollRef.collection('votes').doc(uid));
        }
      }

      // 3. Decrement petition counts and remove signature records
      for (final doc in signedPetitionsSnap.docs) {
        final petitionId = doc.id;
        final petitionRef = db.collection('petitions').doc(petitionId);
        txn.update(petitionRef, {'signatureCount': FieldValue.increment(-1)});
        txn.delete(petitionRef.collection('signatures').doc(uid));
      }

      // 4. Finally delete the user profile
      txn.delete(userRef);
    });
  }

  Stream<UserProfile?> watchById(String uid) {
    return _fs.watchDoc(_doc(uid));
  }

  Stream<List<UserProfile>> watchAll({int? limit}) {
    return _fs.watchCol(_col(), limit: limit);
  }
}
