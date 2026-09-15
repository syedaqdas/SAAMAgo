import * as admin from 'firebase-admin';
import dotenv from 'dotenv';
dotenv.config();

let projectId = process.env.FIREBASE_PROJECT_ID;
let clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
let privateKey = process.env.FIREBASE_PRIVATE_KEY;

if (!projectId || !clientEmail || !privateKey) {
  if (process.env.NODE_ENV !== 'test') {
    console.error("FATAL ERROR: Missing Firebase Admin environment variables.");
    console.error(`FIREBASE_PROJECT_ID configured: ${!!projectId}`);
    console.error(`FIREBASE_CLIENT_EMAIL configured: ${!!clientEmail}`);
    console.error(`FIREBASE_PRIVATE_KEY configured: ${!!privateKey}`);
    process.exit(1);
  } else {
    projectId = 'demo-project';
    clientEmail = 'demo@demo.com';
    privateKey = 'demo';
  }
}

// Safely handle literal '\n' characters from Render ENV and strip accidental quotes
privateKey = privateKey.replace(/\\n/g, '\n').replace(/^"|"$/g, '').replace(/^'|'$/g, '');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  });
}

export const db = admin.firestore();
export const auth = admin.auth();
