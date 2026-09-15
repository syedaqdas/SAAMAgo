import { Router, Request, Response } from 'express';
import crypto from 'crypto';
import { db } from '../config/firebase';

const router = Router();

router.post('/razorpay', async (req: Request, res: Response): Promise<void> => {
  try {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || '';
    const signature = req.headers['x-razorpay-signature'] as string;

    if (!signature) {
      res.status(400).send('Signature missing');
      return;
    }

    // req.body is a raw Buffer because of express.raw()
    const payloadBuffer = req.body;
    
    if (!Buffer.isBuffer(payloadBuffer)) {
      res.status(400).send('Invalid request body type');
      return;
    }

    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(payloadBuffer)
      .digest('hex');

    const expectedBuffer = Buffer.from(expectedSignature);
    const signatureBuffer = Buffer.from(signature);

    if (
      expectedBuffer.length !== signatureBuffer.length ||
      !crypto.timingSafeEqual(expectedBuffer, signatureBuffer)
    ) {
      res.status(400).send('Invalid signature');
      return;
    }

    let parsedBody;
    try {
      parsedBody = JSON.parse(payloadBuffer.toString('utf8'));
    } catch (e) {
      res.status(400).send('Malformed JSON');
      return;
    }

    const event = parsedBody.event;
    const paymentEntity = parsedBody.payload?.payment?.entity;

    if (!paymentEntity) {
      res.status(400).send('Invalid payload structure');
      return;
    }

    const orderId = paymentEntity.order_id;
    const txnsSnapshot = await db.collection('transactions').where('gatewayOrderId', '==', orderId).limit(1).get();
    
    if (txnsSnapshot.empty) {
      res.status(200).send('Transaction not found, ignoring');
      return;
    }

    const txnDoc = txnsSnapshot.docs[0];
    const txnRef = txnDoc.ref;
    const currentStatus = txnDoc.data().status;
    
    if (event === 'payment.captured') {
      if (currentStatus !== 'completed') {
        await txnRef.update({
          status: 'completed',
          gatewayTransactionId: paymentEntity.id,
          webhookVerifiedAt: new Date(),
          updatedAt: new Date(),
        });
      }
    } else if (event === 'payment.failed') {
      if (currentStatus !== 'completed') {
         await txnRef.update({
          status: 'failed',
          updatedAt: new Date(),
        });
      }
    }
    // refund.processed could be added here in the future

    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook Error:', error);
    res.status(500).send('Internal server error');
  }
});

export default router;
