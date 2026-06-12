const { body, param } = require('express-validator');

const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .isLength({ max: 255 })
    .escape(),
  body('password')
    .isLength({ min: 12, max: 128 })
    .notEmpty()
];

const validateGrade = [
  body('grade')
    .isFloat({ min: 0.0, max: 4.0 })
    .notEmpty(),
  param('courseId')
    .isUUID()
    .notEmpty()
];

const validateStudentId = [
  param('studentId')
    .isUUID()
    .custom((value, { req }) => {
      if (req.user.role === 'student' && value !== req.user.sub) {
        throw new Error('Access denied');
      }
      return true;
    })
];

module.exports = { validateLogin, validateGrade, validateStudentId };
