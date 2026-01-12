import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';

void main() {
  late UserRepository userRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late DatabaseService firestoreService;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    locator.setDatabaseForTest(fakeFirebaseFirestore);
    firestoreService = DatabaseService(fakeFirebaseFirestore);
    userRepository = UserRepository(firestoreService);
  });

  group('UserRepository', () {
    final tUserProfile = UserProfile(
      uid: '1',
      displayName: 'Test User',
      email: 'test@example.com',
      state: 'Bayern',
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

    test('watchById returns a stream of UserProfile', () {
      final stream = userRepository.watchById('1');

      expectLater(
        stream,
        emitsInOrder([
          isNull,
          predicate<UserProfile?>((p) => p != null && p.uid == '1'),
        ]),
      );

      userRepository.upsert(tUserProfile);
    });

    test('watchAll returns a stream of list of UserProfile', () async {
      final stream = userRepository.watchAll();

      expect(stream, emits(isEmpty));

      await userRepository.upsert(tUserProfile);

      expect(
        stream,
        emits(
          predicate<List<UserProfile>>(
            (list) => list.isNotEmpty && list.first.uid == '1',
          ),
        ),
      );
    });
  });
}
