"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onAccountDelete = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
if (admin.apps.length === 0) {
    admin.initializeApp();
}
exports.onAccountDelete = functions.auth.user().onDelete(async (user) => {
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
                    }
                    catch (e) {
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
    }
    catch (error) {
        console.error(`[onAccountDelete] Error cleaning up user ${uid}:`, error);
    }
});
function getFilePathFromUrl(url) {
    try {
        const parts = url.split("/o/");
        if (parts.length < 2)
            return null;
        const path = parts[1].split("?")[0];
        return decodeURIComponent(path);
    }
    catch (e) {
        return null;
    }
}
//# sourceMappingURL=user_cleanup.js.map