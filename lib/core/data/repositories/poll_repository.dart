import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:universal_io/io.dart';

class PollRepository {
  PollRepository(this._fs);
  final DatabaseService _fs;

  static PollRepository create() => PollRepository(locator.databaseService);

  CollectionReference<Poll> _col() => _fs.colRef<Poll>(
    'polls',
    fromFirestore: Poll.fromFirestore,
    toFirestore: Poll.toFirestore,
  );

  Stream<List<Poll>> list({String? query, int? limit, required String status}) {
    final q = (query ?? '').trim().toLowerCase();
    final queryRef = _col();

    Stream<List<Poll>> stream;
    if (q.isEmpty) {
      stream = _fs.watchCol<Poll>(
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

    return stream.map((polls) {
      return polls.where((p) => p.status == status).toList();
    });
  }

  Stream<Poll?> watch(String id) {
    final ref = _fs.docRef<Poll>(
      'polls/$id',
      fromFirestore: Poll.fromFirestore,
      toFirestore: Poll.toFirestore,
    );
    return _fs.watchDoc(ref);
  }

  Future<Poll?> get(String id) async {
    final ref = _fs.docRef<Poll>(
      'polls/$id',
      fromFirestore: Poll.fromFirestore,
      toFirestore: Poll.toFirestore,
    );
    final snap = await ref.get();
    return snap.data();
  }

  Future<void> vote({
    required String pollId,
    required String optionId,
    required String uid,
  }) async {
    final db = locator.database;
    final pollRef = db.collection('polls').doc(pollId);
    final voteRef = pollRef.collection('votes').doc(uid);
    final userRef = db.collection('users').doc(uid);

    await db.runTransaction((txn) async {
      final voteSnap = await txn.get(voteRef);
      if (voteSnap.exists) return; // one vote per user
      txn.set(voteRef, {
        'uid': uid,
        'optionId': optionId,
        'votedAt': FieldValue.serverTimestamp(),
      });
      txn.update(pollRef, {'votes.$optionId': FieldValue.increment(1)});
      txn.set(userRef.collection('votedPolls').doc(pollId), {
        'pollId': pollId,
        'optionId': optionId,
        'votedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<String> createPoll(Poll poll) async {
    final docRef = await _col().add(poll);
    return docRef.id;
  }

  Stream<List<UserProfile>> watchParticipants(String pollId) {
    return _fs.instance
        .collection('polls')
        .doc(pollId)
        .collection('votes')
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
  Future<List<UserProfile>> getParticipantsOnce(String pollId) async {
    final snap = await _fs.instance
        .collection('polls')
        .doc(pollId)
        .collection('votes')
        .get();
    final uids = snap.docs.map((d) => d.id).toList();
    if (uids.isEmpty) return [];
    final userRepo = UserRepository.create();
    final profiles = await Future.wait(
      uids.map((uid) => userRepo.getById(uid)),
    );
    return profiles.whereType<UserProfile>().toList();
  }

  // Remove all votes by a user and decrement poll counts (used by user deletion)
  Future<void> removeVotesByUser(String uid) async {
    final db = _fs.instance;
    final votedPollsSnap = await db
        .collection('users')
        .doc(uid)
        .collection('votedPolls')
        .get();
    await db.runTransaction((txn) async {
      for (final doc in votedPollsSnap.docs) {
        final pollId = doc.id;
        final optionId = doc.data()['optionId'] as String?;
        if (optionId != null) {
          final pollRef = db.collection('polls').doc(pollId);
          txn.update(pollRef, {'votes.$optionId': FieldValue.increment(-1)});
          txn.delete(pollRef.collection('votes').doc(uid));
        }
        txn.delete(
          db.collection('users').doc(uid).collection('votedPolls').doc(pollId),
        );
      }
    });
  }

  // Close polls created by a user
  Future<void> closePollsCreatedByUser(String uid) async {
    final batch = _fs.instance.batch();
    final createdPollsSnap = await _col()
        .where('createdBy', isEqualTo: uid)
        .get();
    for (final doc in createdPollsSnap.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
  }

  Future<void> closeExpiredPolls() async {
    final batch = _fs.instance.batch();
    final expired = await _col()
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isLessThan: DateTime.now())
        .get();

    for (final doc in expired.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
  }

  Future<void> delete(String id) async {
    await _col().doc(id).delete();
  }

  // Upload title image for poll and set imageUrl on the poll document.
  Future<String> uploadTitleImage(String pollId, File file) async {
    final storage = locator.storageService;
    final url = await storage.uploadPollTitleImage(pollId, file);
    await _fs.instance.collection('polls').doc(pollId).update({
      'imageUrl': url,
    });
    return url;
  }

  // Delete title image for poll and clear imageUrl field.
  Future<void> deleteTitleImage(String pollId) async {
    final storage = locator.storageService;
    await storage.deletePollTitleImage(pollId);
    await _fs.instance.collection('polls').doc(pollId).update({
      'imageUrl': FieldValue.delete(),
    });
  }
}
