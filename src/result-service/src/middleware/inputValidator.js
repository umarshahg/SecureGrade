const { param } = require('express-validator');

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

module.exports = { validateStudentId };
