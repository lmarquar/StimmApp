import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/firebase/firestore/collections.dart';
import 'package:stimmapp/core/firebase/firestore/firestore_service.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._fs);

  final FirestoreService _fs;

  CollectionReference<UserProfile> _col() {
    return _fs.colRef<UserProfile>(
      FirestoreCollections.users,
      fromFirestore: (snap, _) =>
          UserProfile.fromJson(snap.data() as Map<String, dynamic>, snap.id),
      toFirestore: (model, _) => model.toJson(),
    );
  }

  DocumentReference<UserProfile> _doc(String uid) {
    return _col().doc(uid);
  }

  @override
  Future<UserProfile?> getById(String uid) async {
    return _fs.getDoc(_doc(uid));
  }

  @override
  Future<void> upsert(UserProfile profile) async {
    await _fs.upsert(_doc(profile.uid), profile.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> delete(String uid) {
    return _fs.delete(_doc(uid));
  }

  @override
  Stream<UserProfile?> watchById(String uid) {
    return _fs.watchDoc(_doc(uid));
  }

  @override
  Stream<List<UserProfile>> watchAll({int? limit}) {
    return _fs.watchCol(_col(), limit: limit);
  }
}
