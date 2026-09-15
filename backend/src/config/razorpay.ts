import Razorpay from 'razorpay';
import dotenv from 'dotenv';
dotenv.config();

let instance: Razorpay | null = null;

export const getRazorpay = (): Razorpay | null => {
  if (instance) return instance;

  const key_id = process.env.RAZORPAY_KEY_ID;
  const key_secret = process.env.RAZORPAY_KEY_SECRET;

  if (key_id && key_secret) {
    instance = new Razorpay({ key_id, key_secret });
    return instance;
  }
  
  return null;
};
