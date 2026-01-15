import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyPublishingStatus {
  final bool canCreatePetition;
  final bool canCreatePoll;

  const DailyPublishingStatus({
    required this.canCreatePetition,
    required this.canCreatePoll,
  });
}

class PublishingQuotaService {
  PublishingQuotaService._();
  static final PublishingQuotaService instance = PublishingQuotaService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _todayKeyUtc() {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyPublishing')
        .doc(_todayKeyUtc());
  }

  Future<DailyPublishingStatus> getDailyStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const DailyPublishingStatus(
        canCreatePetition: false,
        canCreatePoll: false,
      );
    }
    final snap = await _doc(uid).get();
    final data = snap.data() ?? const {};
    final petitionCount = (data['petitionCount'] ?? 0) as int;
    final pollCount = (data['pollCount'] ?? 0) as int;
    return DailyPublishingStatus(
      canCreatePetition: petitionCount < 1,
      canCreatePoll: pollCount < 1,
    );
  }

  Future<void> incrementPetition() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user');
    final ref = _doc(uid);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data();
      final count = (data?['petitionCount'] ?? 0) as int;
      if (count >= 1) {
        throw StateError('petition_daily_limit_reached');
      }
      final newData = {
        'petitionCount': count + 1,
        'lastPetitionAt': FieldValue.serverTimestamp(),
        'pollCount': (data?['pollCount'] ?? 0),
        'lastPollAt': data?['lastPollAt'],
      };
      txn.set(ref, newData, SetOptions(merge: true));
    });
  }

  Future<void> incrementPoll() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user');
    final ref = _doc(uid);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data();
      final count = (data?['pollCount'] ?? 0) as int;
      if (count >= 1) {
        throw StateError('poll_daily_limit_reached');
      }
      final newData = {
        'pollCount': count + 1,
        'lastPollAt': FieldValue.serverTimestamp(),
        'petitionCount': (data?['petitionCount'] ?? 0),
        'lastPetitionAt': data?['lastPetitionAt'],
      };
      txn.set(ref, newData, SetOptions(merge: true));
    });
  }
}
