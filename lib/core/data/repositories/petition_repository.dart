import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

class PetitionRepository {
  PetitionRepository(this._fs);
  final DatabaseService _fs;

  static PetitionRepository create() =>
      PetitionRepository(locator.databaseService);

  CollectionReference<Petition> _col() => _fs.colRef<Petition>(
    'petitions',
    fromFirestore: Petition.fromFirestore,
    toFirestore: Petition.toFirestore,
  );

  Stream<List<Petition>> list({String? query, int? limit}) {
    final q = (query ?? '').trim().toLowerCase();
    final ref = _col();
    if (q.isEmpty) {
      return _fs.watchCol<Petition>(
        ref.orderBy('createdAt', descending: true),
        limit: limit,
      );
    }
    // Requires an index on titleLowercase
    return ref
        .where('titleLowercase', isGreaterThanOrEqualTo: q)
        .where('titleLowercase', isLessThan: '$q\uf8ff')
        .orderBy('titleLowercase')
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<Petition?> watch(String id) {
    final ref = _fs.docRef<Petition>(
      'petitions/$id',
      fromFirestore: Petition.fromFirestore,
      toFirestore: Petition.toFirestore,
    );
    return _fs.watchDoc(ref);
  }

  Future<Petition?> get(String id) async {
    final ref = _fs.docRef<Petition>(
      'petitions/$id',
      fromFirestore: Petition.fromFirestore,
      toFirestore: Petition.toFirestore,
    );
    final snap = await ref.get();
    return snap.data();
  }

  Future<String> createPetition(Petition petition) async {
    final docRef = await _col().add(petition);
    return docRef.id;
  }

  Future<void> sign(String petitionId, String uid) async {
    final db = _fs.instance;
    final petitionRef = db.collection('petitions').doc(petitionId);
    final userRef = db.collection('users').doc(uid);
    final signatureRef = petitionRef.collection('signatures').doc(uid);

    await db.runTransaction((txn) async {
      final sigSnap = await txn.get(signatureRef);
      if (sigSnap.exists) return; // idempotent
      txn.set(signatureRef, {
        'uid': uid,
        'signedAt': FieldValue.serverTimestamp(),
      });
      txn.update(petitionRef, {'signatureCount': FieldValue.increment(1)});
      txn.set(userRef.collection('signedPetitions').doc(petitionId), {
        'petitionId': petitionId,
        'signedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSignedPetitions(String uid) {
    return _fs.instance
        .collection('users')
        .doc(uid)
        .collection('signedPetitions')
        .orderBy('signedAt', descending: true)
        .snapshots();
  }
}
