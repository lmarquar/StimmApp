import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

Future<void> updateUsername(String username) async {
  await authService.updateUsername(username: username);
  final userRepository = UserRepository.create();
  final uid = authService.currentUser!.uid;
  final userProfile = await userRepository.getById(uid);
  if (userProfile != null) {
    await userRepository.upsert(userProfile.copyWith(displayName: username));
  } else {
    await userRepository.upsert(UserProfile(uid: uid, displayName: username));
  }
}
