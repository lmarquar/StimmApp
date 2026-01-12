import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';

void main() {
  late PetitionRepository petitionRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late DatabaseService firestoreService;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    firestoreService = DatabaseService(fakeFirebaseFirestore);
    petitionRepository = PetitionRepository(firestoreService);
    locator.setDatabaseForTest(fakeFirebaseFirestore);
  });

  group('PetitionRepository', () {
    final tPetition = Petition(
      id: '1',
      title: 'Test Petition',
      description: 'A test petition',
      tags: [],
      signatureCount: 0,
      createdBy: 'user1',
      createdAt: DateTime(2023),
      expiresAt: DateTime(2024),
    );

    test('createPetition and watch work correctly', () async {
      final petitionId = await petitionRepository.createPetition(tPetition);
      final stream = petitionRepository.watch(petitionId);

      expect(
        stream,
        emits(
          predicate<Petition?>((p) => p != null && p.title == tPetition.title),
        ),
      );
    });

    test('list returns a stream of petitions', () async {
      await petitionRepository.createPetition(tPetition);
      final stream = petitionRepository.list(status: IConst.active);

      expect(
        stream,
        emits(
          predicate<List<Petition>>(
            (list) => list.isNotEmpty && list.first.title == tPetition.title,
          ),
        ),
      );
    });

    test('sign increments the signature count', () async {
      final petitionId = await petitionRepository.createPetition(tPetition);

      await petitionRepository.sign(petitionId, 'user1');

      final petition = await petitionRepository.get(petitionId);
      expect(petition, isNotNull);
      expect(petition!.signatureCount, 1);
    });

    test('a user can only sign once', () async {
      final petitionId = await petitionRepository.createPetition(tPetition);

      await petitionRepository.sign(petitionId, 'user1');
      await petitionRepository.sign(petitionId, 'user1');

      final petition = await petitionRepository.get(petitionId);
      expect(petition, isNotNull);
      expect(petition!.signatureCount, 1);
    });

    test('watchParticipants returns profiles of signers', () async {
      final petitionId = await petitionRepository.createPetition(tPetition);

      // Add a user profile
      final user = UserProfile(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'User One',
      );
      await fakeFirebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());

      // Sign
      await petitionRepository.sign(petitionId, user.uid);

      final participants =
          await petitionRepository.watchParticipants(petitionId).first;

      expect(participants, hasLength(1));
      expect(participants.first.uid, user.uid);
      expect(participants.first.displayName, user.displayName);
    });
  });
}
