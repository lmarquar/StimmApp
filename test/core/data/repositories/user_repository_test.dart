import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

import 'user_repository_test.mocks.dart';

void main() {
  late UserRepository userRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late DatabaseService firestoreService;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockReference;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    mockReference = MockReference();

    locator.setDatabaseForTest(fakeFirebaseFirestore);
    locator.setStorageForTest(mockFirebaseStorage);
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

    test('isAdmin is true for service@stimmapp.org', () {
      const admin = UserProfile(uid: 'admin', email: 'service@stimmapp.org');
      expect(admin.isAdmin, isTrue);
    });

    test('isAdmin is false for other emails', () {
      const user = UserProfile(uid: 'user', email: 'user@test.com');
      expect(user.isAdmin, isFalse);
    });
  });
}
