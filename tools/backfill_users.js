// backfill_users.js
// Usage: node backfill_users.js
// Prerequisites:
// 1) Install firebase-admin: npm install firebase-admin
// 2) Set GOOGLE_APPLICATION_CREDENTIALS env var to a service account JSON with access to Auth and Firestore
// 3) Run from project root: node tools/backfill_users.js

const admin = require('firebase-admin');

// Initialize admin SDK (uses GOOGLE_APPLICATION_CREDENTIALS env var)
admin.initializeApp();
const auth = admin.auth();
const db = admin.firestore();

async function backfill() {
  console.log('Starting backfill of Auth users -> Firestore users collection');
  let nextPageToken = undefined;
  let total = 0;
  try {
    do {
      const list = await auth.listUsers(1000, nextPageToken);
      for (const userRecord of list.users) {
        total++;
        const uid = userRecord.uid;
        const docRef = db.collection('users').doc(uid);
        const doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            email: userRecord.email || null,
            name: userRecord.displayName || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isActive: true,
          });
          console.log(`Created user doc for ${uid}`);
        }
      }
      nextPageToken = list.pageToken;
      // small throttle to avoid overloading
      await sleep(200);
    } while (nextPageToken);
    console.log(`Backfill complete. Processed ${total} users.`);
  } catch (err) {
    console.error('Backfill failed', err);
    process.exit(1);
  }
}

function sleep(ms) {
  return new Promise((res) => setTimeout(res, ms));
}

backfill();

