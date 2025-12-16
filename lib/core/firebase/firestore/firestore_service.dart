import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  FirebaseFirestore get instance => _db;

  CollectionReference<T> colRef<T>(
    String path, {
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return _db
        .collection(path)
        .withConverter<T>(
          fromFirestore: (snap, options) => fromFirestore(snap, options),
          toFirestore: (model, options) => toFirestore(model, options),
        );
  }

  DocumentReference<T> docRef<T>(
    String path, {
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return _db
        .doc(path)
        .withConverter<T>(
          fromFirestore: (snap, options) => fromFirestore(snap, options),
          toFirestore: (model, options) => toFirestore(model, options),
        );
  }

  Future<T?> getDoc<T>(DocumentReference<T> ref) async {
    final snap = await ref.get();
    return snap.data();
  }

  Stream<T?> watchDoc<T>(DocumentReference<T> ref) {
    return ref.snapshots().map((s) => s.data());
  }

  Stream<List<T>> watchCol<T>(Query<T> query, {int? limit}) {
    var q = query;
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> upsert<T>(DocumentReference<T> ref, T data) async {
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> delete<T>(DocumentReference<T> ref) async {
    await ref.delete();
  }
}
