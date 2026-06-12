const db = require('../config/db');
const bcrypt = require('bcrypt');
const { validationResult } = require('express-validator');

const getUsers = async (req, res) => {
  try {
    const users = await db.query(
      `SELECT id, email, role, is_active, created_at
       FROM users
       ORDER BY created_at DESC`
    );
    return res.status(200).json(users.rows);
  } catch (err) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const createUser = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ message: 'Invalid input' });
  }

  const { email, password, role } = req.body;

  try {
    const saltRounds = 12;
    const hash = await bcrypt.hash(password, saltRounds);

    const result = await db.query(
      `INSERT INTO users (email, password_hash, role)
       VALUES ($1, $2, $3) RETURNING id, email, role`,
      [email, hash, role]
    );

    return res.status(201).json(result.rows[0]);
  } catch (err) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const approveGrades = async (req, res) => {
  const { submissionId } = req.params;

  try {
    await db.query(
      `UPDATE grade_submissions
       SET status = 'approved',
           approved_by = $1,
           approved_at = NOW()
       WHERE id = $2`,
      [req.user.sub, submissionId]
    );

    return res.status(200).json({ message: 'Grades approved successfully' });
  } catch (err) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getUsers, createUser, approveGrades };
