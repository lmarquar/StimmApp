import '../models/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> getById(String uid);
  Future<void> upsert(UserProfile profile);
  Future<void> delete(String uid);

  Stream<UserProfile?> watchById(String uid);
  Stream<List<UserProfile>> watchAll({int? limit});
}
