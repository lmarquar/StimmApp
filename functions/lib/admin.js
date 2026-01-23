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
exports.deleteUserByAdmin = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
// Hardcoded admin email matching IConst.adminEmail in your Dart code
const ADMIN_EMAIL = 'service@stimmapp.org';
exports.deleteUserByAdmin = functions.https.onCall(async (data, context) => {
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
    }
    catch (error) {
        console.error("Error deleting user:", error);
        throw new functions.https.HttpsError('internal', 'Unable to delete user.');
    }
});
//# sourceMappingURL=admin.js.map