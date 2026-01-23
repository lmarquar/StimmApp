import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
	admin.initializeApp();
}

export const onAccountDelete = functions.auth.user().onDelete(async (user) => {
	const uid = user.uid;
	const db = admin.firestore();
	const bucket = admin.storage().bucket();

	console.log(`[onAccountDelete] Cleaning up data for user: ${uid}`);

	try {
		// 1. Delete User Profile Document
		await db.collection("users").doc(uid).delete();

		// 2. Delete Petitions created by the user and their images
		const petitionsSnap = await db.collection("petitions").where("createdBy", "==", uid).get();
		const petitionPromises = petitionsSnap.docs.map(async (doc) => {
			const data = doc.data();
			if (data.imageUrl) {
				const filePath = getFilePathFromUrl(data.imageUrl);
				if (filePath) {
					try {
						await bucket.file(filePath).delete();
						console.log(`[onAccountDelete] Deleted image: ${filePath}`);
					} catch (e) {
						console.warn(`[onAccountDelete] Failed to delete image ${filePath}:`, e);
					}
				}
			}
			return doc.ref.delete();
		});
		await Promise.all(petitionPromises);

		// 3. Delete Polls created by the user
		const pollsSnap = await db.collection("polls").where("createdBy", "==", uid).get();
		const pollPromises = pollsSnap.docs.map((doc) => doc.ref.delete());
		await Promise.all(pollPromises);

		console.log(`[onAccountDelete] Cleanup complete for user: ${uid}`);
	} catch (error) {
		console.error(`[onAccountDelete] Error cleaning up user ${uid}:`, error);
	}
});

function getFilePathFromUrl(url: string): string | null {
	try {
		const parts = url.split("/o/");
		if (parts.length < 2) return null;
		const path = parts[1].split("?")[0];
		return decodeURIComponent(path);
	} catch (e) {
		return null;
	}
}