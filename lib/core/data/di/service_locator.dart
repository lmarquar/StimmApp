import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/data/services/auth_service.dart' as auth_glob;
import 'package:stimmapp/core/data/services/database_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late FirebaseFirestore _database;
  late DatabaseService _databaseService;
  late FirebaseAuth _auth;
  late auth_glob.AuthService _authService;

  void init() {
    final app = Firebase.app();
    _database = FirebaseFirestore.instanceFor(app: app);
    _databaseService = DatabaseService(_database);
    _auth = FirebaseAuth.instanceFor(app: app);
    _authService = auth_glob.authService;
  }

  FirebaseFirestore get database => _database;
  DatabaseService get databaseService => _databaseService;
  FirebaseAuth get auth => _auth;
  auth_glob.AuthService get authService => _authService;

  @visibleForTesting
  void setDatabaseForTest(FirebaseFirestore database) {
    _database = database;
    _databaseService = DatabaseService(database);
  }

  @visibleForTesting
  void setAuthForTest(FirebaseAuth auth) {
    _auth = auth;
    _authService = auth_glob.authService;
  }
}

final locator = ServiceLocator();
