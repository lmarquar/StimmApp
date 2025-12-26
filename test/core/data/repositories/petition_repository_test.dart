import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/di/service_locator.dart';

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
      final stream = petitionRepository.list();

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
  });
}
