const express = require('express');
const router = express.Router();
const { login, logout } = require('../controllers/loginController');
const { authenticate } = require('../middleware/authMiddleware');
const { validateLogin } = require('../middleware/inputValidator');

router.post('/login', validateLogin, login);
router.post('/logout', authenticate, logout);

module.exports = router;
