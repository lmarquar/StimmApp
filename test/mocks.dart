import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {
  @override
  String get email => 'test@test.com';
}
