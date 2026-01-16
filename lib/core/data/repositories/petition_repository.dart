import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:universal_io/io.dart';

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

  Stream<List<Petition>> list({
    String? query,
    int? limit,
    required String status,
  }) {
    final q = (query ?? '').trim().toLowerCase();
    final queryRef = _col();

    Stream<List<Petition>> stream;
    if (q.isEmpty) {
      stream = _fs.watchCol<Petition>(
        queryRef.orderBy('createdAt', descending: true),
        limit: limit,
      );
    } else {
      stream = queryRef
          .where('titleLowercase', isGreaterThanOrEqualTo: q)
          .where('titleLowercase', isLessThan: '$q\uf8ff')
          .orderBy('titleLowercase')
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    }

    return stream.map((petitions) {
      return petitions.where((p) => p.status == status).toList();
    });
  }

  Future<void> closeExpiredPetitions() async {
    final batch = _fs.instance.batch();
    final expired = await _col()
        .where('status', isEqualTo: IConst.active)
        .where('expiresAt', isLessThan: DateTime.now())
        .get();

    for (final doc in expired.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
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

  Stream<List<UserProfile>> watchParticipants(String petitionId) {
    return _fs.instance
        .collection('petitions')
        .doc(petitionId)
        .collection('signatures')
        .snapshots()
        .asyncMap((snap) async {
          final uids = snap.docs.map((d) => d.id).toList();
          if (uids.isEmpty) return [];

          final userRepo = UserRepository.create();
          final profiles = await Future.wait(
            uids.map((uid) => userRepo.getById(uid)),
          );
          return profiles.whereType<UserProfile>().toList();
        });
  }

  // Fetch participants once (used by CSV export)
  Future<List<UserProfile>> getParticipantsOnce(String petitionId) async {
    final snap = await _fs.instance
        .collection('petitions')
        .doc(petitionId)
        .collection('signatures')
        .get();
    final uids = snap.docs.map((d) => d.id).toList();
    if (uids.isEmpty) return [];
    final userRepo = UserRepository.create();
    final profiles = await Future.wait(
      uids.map((uid) => userRepo.getById(uid)),
    );
    return profiles.whereType<UserProfile>().toList();
  }

  // Remove all signatures by a user and decrement petition counts (used by user deletion)
  Future<void> removeSignaturesByUser(String uid) async {
    final db = _fs.instance;
    final signedPetitionsSnap = await db
        .collection('users')
        .doc(uid)
        .collection('signedPetitions')
        .get();
    await db.runTransaction((txn) async {
      for (final doc in signedPetitionsSnap.docs) {
        final petitionId = doc.id;
        final petitionRef = db.collection('petitions').doc(petitionId);
        txn.update(petitionRef, {'signatureCount': FieldValue.increment(-1)});
        txn.delete(petitionRef.collection('signatures').doc(uid));
        txn.delete(
          db
              .collection('users')
              .doc(uid)
              .collection('signedPetitions')
              .doc(petitionId),
        );
      }
    });
  }

  // Close petitions created by a user
  Future<void> closePetitionsCreatedByUser(String uid) async {
    final batch = _fs.instance.batch();
    final createdPetitionsSnap = await _col()
        .where('createdBy', isEqualTo: uid)
        .get();
    for (final doc in createdPetitionsSnap.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSignedPetitions(String uid) {
    return _fs.instance
        .collection('users')
        .doc(uid)
        .collection('signedPetitions')
        .orderBy('signedAt', descending: true)
        .snapshots();
  }

  Future<void> delete(String id) async {
    await _col().doc(id).delete();
  }

  // Upload title image for petition and set imageUrl on the petition document.
  Future<String> uploadTitleImage(String petitionId, File file) async {
    final storage = locator.storageService;
    final url = await storage.uploadPetitionTitleImage(petitionId, file);
    await _fs.instance.collection('petitions').doc(petitionId).update({
      'imageUrl': url,
    });
    return url;
  }

  // Delete title image for petition and clear imageUrl field.
  Future<void> deleteTitleImage(String petitionId) async {
    final storage = locator.storageService;
    await storage.deletePetitionTitleImage(petitionId);
    await _fs.instance.collection('petitions').doc(petitionId).update({
      'imageUrl': FieldValue.delete(),
    });
  }
}
