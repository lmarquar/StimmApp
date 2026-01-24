import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';

void main() {
  group('Petition', () {
    final timestamp = Timestamp.fromDate(DateTime(2023));
    final petition = Petition(
      id: 'petition1',
      title: 'Test Petition',
      description: 'This is a test petition.',
      tags: ['test', 'petition'],
      signatureCount: 100,
      createdBy: 'user1',
      createdAt: timestamp.toDate(),
      expiresAt: timestamp.toDate(),
      status: IConst.active,
    );

    final petitionFirestoreData = {
      'title': 'Test Petition',
      'description': 'This is a test petition.',
      'tags': ['test', 'petition'],
      'signatureCount': 100,
      'createdBy': 'user1',
      'createdAt': timestamp,
      'expiresAt': timestamp,
      'status': 'active',
      'titleLowercase': 'test petition',
      'state': null,
      'imageUrl': null,
    };

    test(
      'fromFirestore creates a Petition object from a firestore snapshot',
      () async {
        final firestore = FakeFirebaseFirestore();
        final snap = await firestore
            .collection('petitions')
            .add(petitionFirestoreData);
        final result = Petition.fromFirestore(await snap.get(), null);

        expect(result.id, isNotEmpty);
        expect(result.title, petition.title);
        expect(result.description, petition.description);
        expect(result.tags, petition.tags);
        expect(result.signatureCount, petition.signatureCount);
        expect(result.createdBy, petition.createdBy);
        expect(result.createdAt.year, petition.createdAt.year);
        expect(result.expiresAt, petition.expiresAt);
        expect(result.status, petition.status);
        expect(result.state, petition.state);
      },
    );

    test('toFirestore returns a map from a Petition object', () {
      final result = Petition.toFirestore(petition, null);
      expect(result, petitionFirestoreData);
    });
  });
}
