import { Router, Response } from 'express';
import crypto from 'crypto';
import { authenticate, AuthenticatedRequest } from '../middleware/auth';
import { db } from '../config/firebase';
import { razorpay } from '../config/razorpay';

const router = Router();

router.post('/createOrder', authenticate, async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { transactionId } = req.body;
    const uid = req.user?.uid;

    if (!transactionId) {
      res.status(400).json({ error: 'transactionId is required' });
      return;
    }

    const txnRef = db.collection('transactions').doc(transactionId);
    const txnDoc = await txnRef.get();

    if (!txnDoc.exists) {
      res.status(404).json({ error: 'Transaction not found' });
      return;
    }

    const txnData = txnDoc.data();
    if (txnData?.userId !== uid) {
      res.status(403).json({ error: 'Unauthorized access to transaction' });
      return;
    }

    if (txnData?.status !== 'pending' && txnData?.status !== 'initiated') {
      res.status(400).json({ error: 'Transaction cannot be initiated' });
      return;
    }

    const amount = txnData?.amount;
    if (!amount || amount <= 0) {
      res.status(400).json({ error: 'Invalid transaction amount' });
      return;
    }

    // PREVENT DUPLICATE ORDERS
    if (txnData?.gatewayOrderId) {
      res.json({
        orderId: txnData.gatewayOrderId,
        amount: amount * 100,
        currency: 'INR',
        keyId: process.env.RAZORPAY_KEY_ID,
      });
      return;
    }

    const order = await razorpay.orders.create({
      amount: amount * 100,
      currency: 'INR',
      receipt: transactionId,
    });

    await txnRef.update({
      gatewayOrderId: order.id,
      status: 'initiated',
      updatedAt: new Date(),
    });

    res.json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID,
    });
  } catch (error: any) {
    console.error('Create Order Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/verifyPayment', authenticate, async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const { transactionId, razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;
    const uid = req.user?.uid;

    if (!transactionId || !razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
      res.status(400).json({ error: 'Missing required parameters' });
      return;
    }

    const txnRef = db.collection('transactions').doc(transactionId);
    const txnDoc = await txnRef.get();

    if (!txnDoc.exists) {
      res.status(404).json({ error: 'Transaction not found' });
      return;
    }

    const txnData = txnDoc.data();
    if (txnData?.userId !== uid) {
      res.status(403).json({ error: 'Unauthorized access to transaction' });
      return;
    }

    if (txnData?.gatewayOrderId !== razorpayOrderId) {
      res.status(400).json({ error: 'Order ID mismatch' });
      return;
    }
    
    if (txnData?.status === 'completed') {
      res.json({ success: true, message: 'Already verified' });
      return;
    }

    const secret = process.env.RAZORPAY_KEY_SECRET || '';
    const generatedSignature = crypto
      .createHmac('sha256', secret)
      .update(`${razorpayOrderId}|${razorpayPaymentId}`)
      .digest('hex');

    const generatedBuffer = Buffer.from(generatedSignature);
    const providedBuffer = Buffer.from(razorpaySignature);

    // FIX: Check buffer lengths before timingSafeEqual to avoid 500 error
    if (
      generatedBuffer.length !== providedBuffer.length ||
      !crypto.timingSafeEqual(generatedBuffer, providedBuffer)
    ) {
      res.status(400).json({ error: 'Invalid payment signature' });
      return;
    }

    await txnRef.update({
      status: 'completed',
      gatewayTransactionId: razorpayPaymentId,
      verifiedAt: new Date(),
      updatedAt: new Date(),
    });

    res.json({ success: true });
  } catch (error: any) {
    console.error('Verify Payment Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
