const jwt = require('jsonwebtoken');
const sessionService = require('../services/sessionService');

const authenticate = async (req, res, next) => {
  const token = req.cookies.token;

  if (!token) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_PUBLIC_KEY, {
      algorithms: ['RS256']
    });

    const isBlacklisted = await sessionService.isBlacklisted(token);
    if (isBlacklisted) {
      return res.status(401).json({ message: 'Token invalidated' });
    }

    req.user = decoded;
    next();

  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

const authorize = (allowedRoles) => {
  return (req, res, next) => {
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    next();
  };
};

module.exports = { authenticate, authorize };
