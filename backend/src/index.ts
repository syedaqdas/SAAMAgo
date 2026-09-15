import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import paymentsRouter from './routes/payments';
import webhooksRouter from './routes/webhooks';

dotenv.config();

const app = express();
app.use(cors());

// Webhooks MUST receive raw body for signature verification
app.use('/webhooks', express.raw({ type: 'application/json' }), webhooksRouter);

// Standard parsed JSON for other routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/payments', paymentsRouter);

app.get('/', (req, res) => {
  res.send('SAAMAgo API is running');
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'saamago-backend' });
});

const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;
