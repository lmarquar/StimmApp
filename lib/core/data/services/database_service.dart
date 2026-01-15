import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  DatabaseService(this._db);

  final FirebaseFirestore _db;

  FirebaseFirestore get instance => _db;

  Future<void> disableNetwork() async {
    try {
      await _db.disableNetwork();
    } on FirebaseException catch (e) {
      throw DatabaseException(e);
    }
  }

  Future<void> enableNetwork() async {
    try {
      await _db.enableNetwork();
    } on FirebaseException catch (e) {
      throw DatabaseException(e);
    }
  }

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
    try {
      final snap = await ref.get();
      return snap.data();
    } on FirebaseException catch (e) {
      throw DatabaseException(e);
    }
  }

  Stream<T?> watchDoc<T>(DocumentReference<T> ref) {
    return ref.snapshots().map((s) => s.data()).handleError((e) {
      if (e is FirebaseException) {
        throw DatabaseException(e);
      }
      throw e;
    });
  }

  Stream<List<T>> watchCol<T>(Query<T> query, {int? limit}) {
    var q = query;
    if (limit != null) q = q.limit(limit);
    return q
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList())
        .handleError((e) {
          if (e is FirebaseException) {
            throw DatabaseException(e);
          }
          throw e;
        });
  }

  Future<void> upsert<T>(DocumentReference<T> ref, T data) async {
    try {
      await ref.set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DatabaseException(e);
    }
  }

  Future<void> delete<T>(DocumentReference<T> ref) async {
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(e);
    }
  }
}

class DatabaseException implements Exception {
  final FirebaseException firestoreException;

  DatabaseException(this.firestoreException);

  String? get message => firestoreException.message;
  String get code => firestoreException.code;

  @override
  String toString() {
    return 'DatabaseException (code: $code): $message';
  }
}
