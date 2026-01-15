import 'package:firebase_auth/firebase_auth.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';

final AuthService authService = AuthService();

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Add email verification here
      await cred.user?.sendEmailVerification();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> updateUsername({required String username}) async {
    try {
      await currentUser!.updateDisplayName(username);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final uid = currentUser?.uid;
      await currentUser!.reauthenticateWithCredential(credential);
      if (uid != null) {
        await UserRepository.create().delete(uid);
      }
      await currentUser!.delete();
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> resetPasswordfromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> setSettings({
    bool appVerificationDisabledForTesting = false,
  }) async {
    try {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: appVerificationDisabledForTesting,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e);
    }
  }
}

class AuthException implements Exception {
  final FirebaseAuthException firebaseAuthException;

  AuthException(this.firebaseAuthException);

  String? get message => firebaseAuthException.message;
  String get code => firebaseAuthException.code;

  @override
  String toString() {
    return 'AuthException (code: $code): $message';
  }
}
