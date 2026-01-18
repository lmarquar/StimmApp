import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';

class SubscriptionManager {
  final FirebaseFirestore _firestore;

  SubscriptionManager({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Checks all users marked as 'isPro' and revokes their status if
  /// the subscription period (30 days) has passed.
  ///
  /// Returns the number of memberships revoked.
  ///
  /// NOTE: This should ideally be run by a scheduled backend task (e.g. Cloud Functions)
  /// to ensure it runs even if no users are logged in.
  Future<int> revokeExpiredMemberships() async {
    log('Starting daily subscription expiration check...');
    int revokedCount = 0;
    final now = DateTime.now();

    // 1. Query all users who are currently Pro.
    // In a very large DB, you would need to paginate this query.
    final query = _firestore
        .collection('users')
        .where('isPro', isEqualTo: true);
    final snapshot = await query.get();

    log('Found ${snapshot.docs.length} Pro users to check.');

    WriteBatch batch = _firestore.batch();
    int batchOpCount = 0;

    for (final doc in snapshot.docs) {
      try {
        final user = UserProfile.fromJson(doc.data(), doc.id);
        final expiresAt = user.subscriptionEndsAt;

        // If date is missing or date is in the past, revoke.
        if (expiresAt == null || now.isAfter(expiresAt)) {
          log('Revoking Pro for user ${user.uid}. Expired: $expiresAt');

          batch.update(doc.reference, {
            'isPro': false,
            'wentProAt': null,
            // Optional: You might want to store 'lastProExpiry' for history
            'updatedAt': FieldValue.serverTimestamp(),
          });

          revokedCount++;
          batchOpCount++;

          // Firestore batches are limited to 500 operations.
          // Commit and start a new batch if we approach the limit.
          if (batchOpCount >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            batchOpCount = 0;
          }
        }
      } catch (e) {
        log('Error processing user ${doc.id}: $e');
      }
    }

    // Commit any remaining operations
    if (batchOpCount > 0) {
      await batch.commit();
    }

    log('Subscription check complete. Revoked $revokedCount memberships.');
    return revokedCount;
  }
}
