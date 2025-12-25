import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/data/firebase/firestore/database_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late FirebaseFirestore _firestore;
  late DatabaseService _databaseService;

  void init() {
    _firestore = FirebaseFirestore.instance;
    _databaseService = DatabaseService(_firestore);
  }

  FirebaseFirestore get firestore => _firestore;
  DatabaseService get databaseService => _databaseService;

  @visibleForTesting
  void setFirestoreForTest(FirebaseFirestore firestore) {
    _firestore = firestore;
    _databaseService = DatabaseService(firestore);
  }
}

final locator = ServiceLocator();
