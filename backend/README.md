# SAAMAgo Payment Backend

Trusted backend for Razorpay order creation, payment signature verification, and secure Firestore transaction updates.

## Setup
1. `npm install`
2. Copy `.env.example` to `.env` and fill placeholders.
3. `npm run dev` for development, `npm run build` && `npm start` for production.

## Environment Variables
- `RAZORPAY_KEY_ID`: Your test/live Key ID
- `RAZORPAY_KEY_SECRET`: Your test/live Key Secret (NEVER SHARE)
- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_CLIENT_EMAIL`: Service account email
- `FIREBASE_PRIVATE_KEY`: Service account private key
- `RAZORPAY_WEBHOOK_SECRET`: Secret to verify incoming webhooks

## Security Model
- Flutter sends Firebase ID token.
- Backend verifies token to authorize operations.
- Order is created server-side to prevent tampering.
- Verification checks HMAC SHA256 signature using `RAZORPAY_KEY_SECRET`.
- Only backend can update `status` to `completed` in Firestore (`firestore.rules` blocks clients).
