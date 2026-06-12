require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const resultRoutes = require('./routes/resultRoutes');

const app = express();

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'"],
      imgSrc: ["'self'", "data:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'none'"],
      frameSrc: ["'none'"],
      frameAncestors: ["'none'"],
      formAction: ["'self'"],
      baseUri: ["'self'"],
      upgradeInsecureRequests: []
    }
  },
  hsts: { maxAge: 31536000, includeSubDomains: true },
  noSniff: true,
  frameguard: { action: 'deny' }
}));
app.use(cookieParser());
app.use(express.json({ limit: '10kb' }));
app.get('/health', (req, res) => res.status(200).json({ status: 'ok', service: 'result' }));
app.use('/api/results', resultRoutes);

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Result service running on port ${PORT}`);
  console.log('JWT_PUBLIC_KEY loaded:', !!process.env.JWT_PUBLIC_KEY);
});

module.exports = app;
