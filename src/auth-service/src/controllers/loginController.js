const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const db = require('../config/db');
const auditService = require('../services/auditService');
const sessionService = require('../services/sessionService');

const login = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ message: 'Invalid credentials' });
  }

  const { email, password } = req.body;

  try {
    const result = await db.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );

    const user = result.rows[0];

    if (!user) {
      await auditService.log('LOGIN_FAILED', { email, ip: req.ip });
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      await auditService.log('LOGIN_FAILED', { email, ip: req.ip });
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { sub: user.id, role: user.role, email: user.email },
      process.env.JWT_PRIVATE_KEY,
      { algorithm: 'RS256', expiresIn: '24h' }
    );

    await sessionService.create(user.id, token);

    await auditService.log('LOGIN_SUCCESS', {
      userId: user.id,
      ip: req.ip,
      timestamp: new Date().toISOString()
    });

    res.cookie('token', token, {
      httpOnly: true,
      secure: false,
      sameSite: 'lax',
      maxAge: 15 * 60 * 1000
    });

    return res.status(200).json({ message: 'Login successful' });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const logout = async (req, res) => {
  const token = req.cookies.token;
  if (token) {
    await sessionService.destroy(req.user.sub);
    await sessionService.blacklist(token);
  }
  res.clearCookie('token');
  await auditService.log('LOGOUT', { userId: req.user?.sub, ip: req.ip });
  return res.status(200).json({ message: 'Logged out successfully' });
};

module.exports = { login, logout };
