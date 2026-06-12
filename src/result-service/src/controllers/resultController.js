const db = require('../config/db');
const { validationResult } = require('express-validator');

const getMyResults = async (req, res) => {
  try {
    const studentId = req.user.sub;

    const results = await db.query(
      `SELECT course_name, grade, semester, gpa
       FROM results
       WHERE student_id = $1
       ORDER BY semester DESC`,
      [studentId]
    );

    return res.status(200).json(results.rows);
  } catch (err) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const getResultById = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ message: 'Invalid request' });
  }

  const { studentId } = req.params;
  const requestingUser = req.user;

  try {
    if (requestingUser.role === 'teacher') {
      const assigned = await db.query(
        `SELECT 1 FROM course_assignments
         WHERE teacher_id = $1 AND student_id = $2`,
        [requestingUser.sub, studentId]
      );
      if (!assigned.rows[0]) {
        return res.status(403).json({ message: 'Forbidden' });
      }
    }

    const results = await db.query(
      'SELECT * FROM results WHERE student_id = $1',
      [studentId]
    );

    return res.status(200).json(results.rows);
  } catch (err) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getMyResults, getResultById };
