const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { getUsers, createUser, approveGrades } = require('../controllers/adminController');
const { authenticate, authorize } = require('../middleware/authMiddleware');

const adminLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,
  handler: (req, res) => {
    return res.status(429).json({ message: 'Too many requests' });
  }
});

router.get('/users',
  adminLimiter,
  authenticate,
  authorize(['admin']),
  getUsers
);

router.post('/users',
  adminLimiter,
  authenticate,
  authorize(['admin']),
  createUser
);

router.put('/grades/approve/:submissionId',
  adminLimiter,
  authenticate,
  authorize(['admin']),
  approveGrades
);

module.exports = router;
