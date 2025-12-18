import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/firebase/firestore/firestore_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final FirebaseFirestore _firestore;
  late final FirestoreService _firestoreService;

  void init() {
    _firestore = FirebaseFirestore.instance;
    _firestoreService = FirestoreService(_firestore);
  }

  FirebaseFirestore get firestore => _firestore;
  FirestoreService get firestoreService => _firestoreService;
}

final locator = ServiceLocator();
