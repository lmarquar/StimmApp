import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/data/firebase/firestore/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late FirebaseFirestore _firestore;
  late DatabaseService _databaseService;
  late FirebaseAuth _auth;
  late AuthService _authService;

  void init() {
    _firestore = FirebaseFirestore.instance;
    _databaseService = DatabaseService(_firestore);
    _auth = FirebaseAuth.instance;
    _authService = AuthService();
  }

  FirebaseFirestore get firestore => _firestore;
  DatabaseService get databaseService => _databaseService;
  FirebaseAuth get auth => _auth;
  AuthService get authService => _authService;

  @visibleForTesting
  void setFirestoreForTest(FirebaseFirestore firestore) {
    _firestore = firestore;
    _databaseService = DatabaseService(firestore);
  }

  @visibleForTesting
  void setAuthForTest(FirebaseAuth auth) {
    _auth = auth;
    _authService = AuthService();
  }
}

final locator = ServiceLocator();
