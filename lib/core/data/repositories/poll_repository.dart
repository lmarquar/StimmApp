import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/di/service_locator.dart';
import 'package:stimmapp/core/data/firebase/firestore/firestore_service.dart';

class PollRepository {
  PollRepository(this._fs);
  final FirestoreService _fs;

  static PollRepository create() => PollRepository(locator.firestoreService);

  CollectionReference<Poll> _col() => _fs.colRef<Poll>(
    'polls',
    fromFirestore: Poll.fromFirestore,
    toFirestore: Poll.toFirestore,
  );

  Stream<List<Poll>> list({String? query, int? limit}) {
    final q = (query ?? '').trim().toLowerCase();
    final ref = _col();
    if (q.isEmpty) {
      return _fs.watchCol<Poll>(
        ref.orderBy('createdAt', descending: true),
        limit: limit,
      );
    }
    return ref
        .where('titleLowercase', isGreaterThanOrEqualTo: q)
        .where('titleLowercase', isLessThan: '$q\uf8ff')
        .orderBy('titleLowercase')
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
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
    final db = locator.firestore;
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
}
