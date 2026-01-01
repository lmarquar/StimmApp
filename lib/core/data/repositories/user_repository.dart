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

  Future<void> delete(String uid) {
    return _fs.delete(_doc(uid));
  }

  Stream<UserProfile?> watchById(String uid) {
    return _fs.watchDoc(_doc(uid));
  }

  Stream<List<UserProfile>> watchAll({int? limit}) {
    return _fs.watchCol(_col(), limit: limit);
  }
}
