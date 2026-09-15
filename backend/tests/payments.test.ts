import request from 'supertest';
import app from '../src/index';
import crypto from 'crypto';

const mockUpdate = jest.fn();
const mockGet = jest.fn();

jest.mock('firebase-admin', () => {
  const auth = { verifyIdToken: jest.fn() };
  const firestore = {
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        get: mockGet,
        update: mockUpdate,
      })),
      where: jest.fn(() => ({
        limit: jest.fn(() => ({
          get: mockGet
        }))
      }))
    })),
  };
  return {
    apps: [],
    initializeApp: jest.fn(),
    credential: { cert: jest.fn() },
    auth: jest.fn(() => auth),
    firestore: jest.fn(() => firestore),
  };
});

jest.mock('razorpay', () => {
  return jest.fn().mockImplementation(() => ({
    orders: { create: jest.fn() },
  }));
});

import * as admin from 'firebase-admin';
import { getRazorpay } from '../src/config/razorpay';

describe('Payments API', () => {
  beforeEach(() => { 
    jest.clearAllMocks(); 
    process.env.RAZORPAY_KEY_ID = 'test_id';
    process.env.RAZORPAY_KEY_SECRET = 'secret';
    process.env.RAZORPAY_WEBHOOK_SECRET = 'whsec_secret';
  });

  describe('POST /createOrder', () => {
    it('should fail without auth', async () => {
      const res = await request(app).post('/payments/createOrder').send({ transactionId: '123' });
      expect(res.status).toBe(401);
    });

    it('should return 404 for non-existent transaction', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({ exists: false });

      const res = await request(app).post('/payments/createOrder')
        .set('Authorization', 'Bearer token').send({ transactionId: 'txn1' });
      expect(res.status).toBe(404);
    });

    it('should reuse existing gatewayOrderId (Duplicate-order prevention)', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({
        exists: true,
        data: () => ({ userId: 'user1', status: 'initiated', amount: 100, gatewayOrderId: 'order_exist123' })
      });

      const res = await request(app).post('/payments/createOrder')
        .set('Authorization', 'Bearer token').send({ transactionId: 'txn1' });
      
      expect(res.status).toBe(200);
      expect(res.body.orderId).toBe('order_exist123');
      const rzp = getRazorpay();
      expect(rzp?.orders.create).not.toHaveBeenCalled();
    });

    it('should enforce transaction ownership', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({
        exists: true,
        data: () => ({ userId: 'differentUser', status: 'pending', amount: 100 })
      });

      const res = await request(app).post('/payments/createOrder')
        .set('Authorization', 'Bearer token').send({ transactionId: 'txn1' });
      
      expect(res.status).toBe(403);
    });
  });

  describe('POST /verifyPayment', () => {
    it('should return 400 for incorrect length signature', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({
        exists: true,
        data: () => ({ userId: 'user1', status: 'initiated', gatewayOrderId: 'order_123' })
      });

      const res = await request(app).post('/payments/verifyPayment')
        .set('Authorization', 'Bearer token')
        .send({
          transactionId: 'txn1',
          razorpayOrderId: 'order_123',
          razorpayPaymentId: 'pay_123',
          razorpaySignature: 'short_sig_does_not_match_length'
        });
      
      expect(res.status).toBe(400);
      expect(res.body.error).toBe('Invalid payment signature');
    });

    it('should return 400 for valid-length but invalid signature', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({
        exists: true,
        data: () => ({ userId: 'user1', status: 'initiated', gatewayOrderId: 'order_123' })
      });

      const invalidSig = '0'.repeat(64); // 64 chars like sha256 hex
      const res = await request(app).post('/payments/verifyPayment')
        .set('Authorization', 'Bearer token')
        .send({
          transactionId: 'txn1',
          razorpayOrderId: 'order_123',
          razorpayPaymentId: 'pay_123',
          razorpaySignature: invalidSig
        });
      
      expect(res.status).toBe(400);
      expect(res.body.error).toBe('Invalid payment signature');
    });

    it('should succeed for valid signature', async () => {
      (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'user1' });
      mockGet.mockResolvedValueOnce({
        exists: true,
        data: () => ({ userId: 'user1', status: 'initiated', gatewayOrderId: 'order_123' })
      });

      const validSig = crypto.createHmac('sha256', 'secret').update('order_123|pay_123').digest('hex');

      const res = await request(app).post('/payments/verifyPayment')
        .set('Authorization', 'Bearer token')
        .send({
          transactionId: 'txn1',
          razorpayOrderId: 'order_123',
          razorpayPaymentId: 'pay_123',
          razorpaySignature: validSig
        });
      
      expect(res.status).toBe(200);
      expect(mockUpdate).toHaveBeenCalledWith(expect.objectContaining({ status: 'completed' }));
    });
  });

  describe('POST /webhooks/razorpay', () => {
    it('should reject missing signature', async () => {
      const res = await request(app).post('/webhooks/razorpay').send({ event: 'test' });
      expect(res.status).toBe(400);
    });

    it('should reject invalid signature', async () => {
      const rawString = JSON.stringify({ event: 'test' });
      const res = await request(app)
        .post('/webhooks/razorpay')
        .set('Content-Type', 'application/json')
        .set('x-razorpay-signature', '0'.repeat(64))
        .send(rawString);
      expect(res.status).toBe(400);
    });

    it('should handle malformed JSON after valid signature safely', async () => {
      const rawString = "{ bad_json ";
      const validSig = crypto.createHmac('sha256', 'whsec_secret').update(rawString, 'utf8').digest('hex');

      const res = await request(app)
        .post('/webhooks/razorpay')
        .set('Content-Type', 'application/json')
        .set('x-razorpay-signature', validSig)
        .send(rawString);

      expect(res.status).toBe(400);
      expect(res.text).toBe('Malformed JSON');
    });

    it('should succeed with valid raw body signature', async () => {
      const payload = {
        event: 'payment.captured',
        payload: { payment: { entity: { order_id: 'order_123', id: 'pay_123' } } }
      };
      const rawString = JSON.stringify(payload);
      const validSig = crypto.createHmac('sha256', 'whsec_secret').update(rawString, 'utf8').digest('hex');

      const mockRef = { update: mockUpdate };
      mockGet.mockResolvedValueOnce({
        empty: false,
        docs: [{ data: () => ({ status: 'initiated' }), ref: mockRef }]
      });

      const res = await request(app)
        .post('/webhooks/razorpay')
        .set('Content-Type', 'application/json')
        .set('x-razorpay-signature', validSig)
        .send(rawString);

      expect(res.status).toBe(200);
      expect(mockUpdate).toHaveBeenCalledWith(expect.objectContaining({ status: 'completed' }));
    });
  });
});
