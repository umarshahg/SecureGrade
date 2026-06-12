const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const adminRoutes = require('./routes/adminRoutes');

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
app.get('/health', (req, res) => res.status(200).json({ status: 'ok', service: 'admin' }));
app.use('/api/admin', adminRoutes);

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => console.log(`Admin service running on port ${PORT}`));

module.exports = app;
