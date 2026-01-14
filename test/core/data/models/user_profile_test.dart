import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    final timestamp = Timestamp.fromDate(DateTime(2023));
    final userProfile = UserProfile(
      uid: '123',
      displayName: 'Test User',
      state: 'Hessen',
      email: 'test@example.com',
      createdAt: timestamp.toDate(),
      updatedAt: timestamp.toDate(),
    );

    final userProfileJson = {
      'displayName': 'Test User',
      'email': 'test@example.com',
      'state': 'Hessen',
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'surname': null,
      'givenName': null,
      'dateOfBirth': null,
      'nationality': null,
      'placeOfBirth': null,
      'expiryDate': null,
      'idNumber': null,
      'address': null,
      'height': null,
    };

    test('fromJson creates a UserProfile object from a map', () {
      final result = UserProfile.fromJson(userProfileJson, '123');
      expect(result.uid, userProfile.uid);
      expect(result.displayName, userProfile.displayName);
      expect(result.email, userProfile.email);
      expect(result.createdAt, userProfile.createdAt);
      expect(result.updatedAt, userProfile.updatedAt);
      expect(result.state, userProfile.state);
    });

    test('toJson returns a map from a UserProfile object', () {
      final result = userProfile.toJson();
      expect(result, userProfileJson);
    });
  });
}
