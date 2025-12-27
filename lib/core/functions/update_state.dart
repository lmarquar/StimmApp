import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

Future<void> updateState(String state) async {
  final userRepository = UserRepository.create();
  final uid = authService.value.currentUser!.uid;
  final userProfile = await userRepository.getById(uid);
  if (userProfile != null) {
    await userRepository.upsert(userProfile.copyWith(state: state));
  } else {
    await userRepository.upsert(UserProfile(uid: uid, state: state));
  }
}
