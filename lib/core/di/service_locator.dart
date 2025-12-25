import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/data/firebase/firestore/firestore_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late FirebaseFirestore _firestore;
  late FirestoreService _firestoreService;

  void init() {
    _firestore = FirebaseFirestore.instance;
    _firestoreService = FirestoreService(_firestore);
  }

  FirebaseFirestore get firestore => _firestore;
  FirestoreService get firestoreService => _firestoreService;

  @visibleForTesting
  void setFirestoreForTest(FirebaseFirestore firestore) {
    _firestore = firestore;
    _firestoreService = FirestoreService(firestore);
  }
}

final locator = ServiceLocator();
