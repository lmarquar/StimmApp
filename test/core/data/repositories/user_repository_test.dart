import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/firebase/firestore/firestore_service.dart';

void main() {
  late UserRepository userRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late FirestoreService firestoreService;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(fakeFirebaseFirestore);
    userRepository = UserRepository(firestoreService);
  });

  group('UserRepository', () {
    final tUserProfile = UserProfile(
      uid: '1',
      displayName: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime(2023),
      updatedAt: DateTime(2023),
    );

    test('upsert and getById work correctly', () async {
      await userRepository.upsert(tUserProfile);
      final result = await userRepository.getById('1');

      expect(result, isNotNull);
      expect(result!.uid, tUserProfile.uid);
      expect(result.displayName, tUserProfile.displayName);
    });

    test('delete removes the user', () async {
      await userRepository.upsert(tUserProfile);
      var result = await userRepository.getById('1');
      expect(result, isNotNull);

      await userRepository.delete('1');
      result = await userRepository.getById('1');
      expect(result, isNull);
    });

    test('watchById returns a stream of UserProfile', () async {
      final stream = userRepository.watchById('1');
      
      expect(stream, emits(isNull));

      await userRepository.upsert(tUserProfile);

      expect(stream, emits(predicate<UserProfile?>((p) => p != null && p.uid == '1')));
    });

    test('watchAll returns a stream of list of UserProfile', () async {
      final stream = userRepository.watchAll();

      expect(stream, emits(isEmpty));

      await userRepository.upsert(tUserProfile);

      expect(stream, emits(predicate<List<UserProfile>>((list) => list.isNotEmpty && list.first.uid == '1')));
    });
  });
}
