import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const checkSubscriptions = functions.pubsub.schedule('every day 00:00').onRun(async (context) => {
	const db = admin.firestore();
	const now = new Date();

	// Query all users who are currently Pro
	const snapshot = await db.collection('users').where('isPro', '==', true).get();

	console.log(`Found ${snapshot.size} Pro users to check.`);

	let batch = db.batch();
	let operationCount = 0;
	let revokedCount = 0;

	for (const doc of snapshot.docs) {
		const data = doc.data();
		// In Firestore, dates are stored as Timestamps
		const wentProAt = data.wentProAt as admin.firestore.Timestamp | undefined;

		let shouldRevoke = false;

		if (!wentProAt) {
			// Data inconsistency: marked as Pro but no start date. Revoke to fix state.
			shouldRevoke = true;
		} else {
			const startDate = wentProAt.toDate();
			// Calculate expiration: start date + 30 days
			const expirationDate = new Date(startDate);
			expirationDate.setDate(startDate.getDate() + 30);

			if (now > expirationDate) {
				shouldRevoke = true;
			}
		}

		if (shouldRevoke) {
			batch.update(doc.ref, {
				isPro: false,
				wentProAt: null,
				updatedAt: admin.firestore.FieldValue.serverTimestamp(),
			});

			operationCount++;
			revokedCount++;

			// Firestore batches allow up to 500 operations.
			if (operationCount >= 400) {
				await batch.commit();
				batch = db.batch();
				operationCount = 0;
			}
		}
	}

	if (operationCount > 0) {
		await batch.commit();
	}

	console.log(`Subscription check complete. Revoked ${revokedCount} memberships.`);
	return null;
});