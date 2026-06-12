const jwt = require('jsonwebtoken');

const authenticate = async (req, res, next) => {
  const token = req.cookies.token;

  if (!token) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const publicKey = process.env.JWT_PUBLIC_KEY;
    console.log('Using key length:', publicKey?.length);
    console.log('Token received:', token?.substring(0, 20));

    const decoded = jwt.verify(token, publicKey, {
      algorithms: ['RS256']
    });

    req.user = decoded;
    next();

  } catch (err) {
    console.error('JWT verification failed');
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
