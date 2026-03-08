# Backfill Auth users -> Firestore users collection

This script iterates all Firebase Authentication users and creates a minimal Firestore document under `users/{uid}` when missing.

Prerequisites
- Node.js installed
- `npm install firebase-admin`
- A Firebase service account key JSON with Firestore & Auth permissions
- Set environment var: `GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccountKey.json`

Run
```
node tools/backfill_users.js
```

Notes
- The script uses the Admin SDK and must be run from a secure environment (your machine or a trusted server).
- It creates minimal user docs. Customize the fields as needed.

