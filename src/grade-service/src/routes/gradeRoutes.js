const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { uploadGrades } = require('../controllers/gradeController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { upload } = require('../middleware/fileValidator');

const gradeLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  handler: (req, res) => {
    return res.status(429).json({ message: 'Too many requests' });
  }
});

router.post('/upload',
  gradeLimiter,
  authenticate,
  authorize(['teacher']),
  upload.single('file'),
  uploadGrades
);

module.exports = router;
