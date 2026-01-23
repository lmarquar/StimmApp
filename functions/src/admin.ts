import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

// Hardcoded admin email matching IConst.adminEmail in your Dart code
const ADMIN_EMAIL = 'service@stimmapp.org';

export const deleteUserByAdmin = functions.https.onCall(async (data, context) => {
	// 1. Ensure the caller is authenticated
	if (!context.auth) {
		throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
	}

	// 2. Ensure the caller is the Admin
	const callerEmail = context.auth.token.email;
	if (callerEmail !== ADMIN_EMAIL) {
		throw new functions.https.HttpsError('permission-denied', 'Only admins can delete users.');
	}

	const uid = data.uid;
	if (!uid) {
		throw new functions.https.HttpsError('invalid-argument', 'The function must be called with a "uid" argument.');
	}

	try {
		// 3. Delete from Authentication (this triggers onAccountDelete in user_cleanup.ts)
		await admin.auth().deleteUser(uid);

		// 4. Delete from Firestore immediately so the UI updates instantly
		await admin.firestore().collection('users').doc(uid).delete();

		return { success: true };
	} catch (error) {
		console.error("Error deleting user:", error);
		throw new functions.https.HttpsError('internal', 'Unable to delete user.');
	}
});