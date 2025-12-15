import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/repositories/firestore_user_repository.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/firebase/firestore/firestore_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final FirebaseFirestore _firestore;
  late final FirestoreService _firestoreService;
  late final UserRepository _userRepository;

  void init() {
    _firestore = FirebaseFirestore.instance;
    _firestoreService = FirestoreService(_firestore);
    _userRepository = FirestoreUserRepository(_firestoreService);
  }

  FirebaseFirestore get firestore => _firestore;
  FirestoreService get firestoreService => _firestoreService;
  UserRepository get userRepository => _userRepository;
}

final locator = ServiceLocator();
