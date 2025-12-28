import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/constants/constants.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late FirebaseFirestore _database;
  late DatabaseService _databaseService;
  late FirebaseAuth _auth;
  late AuthService _authService;

  void init() {
    final app = Firebase.app(KConst.appName);
    _database = FirebaseFirestore.instanceFor(app: app);
    _databaseService = DatabaseService(_database);
    _auth = FirebaseAuth.instanceFor(app: app);
    _authService = AuthService();
  }

  FirebaseFirestore get database => _database;
  DatabaseService get databaseService => _databaseService;
  FirebaseAuth get auth => _auth;
  AuthService get authService => _authService;

  @visibleForTesting
  void setDatabaseForTest(FirebaseFirestore database) {
    _database = database;
    _databaseService = DatabaseService(database);
  }

  @visibleForTesting
  void setAuthForTest(FirebaseAuth auth) {
    _auth = auth;
    _authService = AuthService();
  }
}

final locator = ServiceLocator();
