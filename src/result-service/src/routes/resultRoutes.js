const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { getMyResults, getResultById } = require('../controllers/resultController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { validateStudentId } = require('../middleware/inputValidator');

const resultLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  handler: (req, res) => {
    return res.status(429).json({ message: 'Too many requests' });
  }
});

router.get('/me',
  resultLimiter,
  authenticate,
  authorize(['student']),
  getMyResults
);

router.get('/:studentId',
  resultLimiter,
  authenticate,
  authorize(['teacher','admin']),
  validateStudentId,
  getResultById
);

module.exports = router;
