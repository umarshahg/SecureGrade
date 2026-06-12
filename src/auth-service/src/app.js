require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const { doubleCsrf } = require('csrf-csrf');
const { loginLimiter, apiLimiter } = require('./middleware/rateLimiter');
const authRoutes = require('./routes/authRoutes');

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

const { doubleCsrfProtection } = doubleCsrf({
  getSecret: () => process.env.CSRF_SECRET || 'csrf-secret-key',
  cookieName: 'csrf-token',
  cookieOptions: { sameSite: 'lax', secure: false }
});

app.use('/api/auth', apiLimiter);
app.use('/api/auth/login', loginLimiter);
app.get('/health', (req, res) => res.status(200).json({ status: 'ok', service: 'auth' }));
app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Auth service running on port ${PORT}`));

module.exports = app;
