const rateLimit = require('express-rate-limit');
const { RedisStore } = require('rate-limit-redis');
const redis = require('../config/redis');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  store: new RedisStore({
    sendCommand: (...args) => redis.sendCommand(args)
  }),
  handler: (req, res) => {
    return res.status(429).json({
      message: 'Too many login attempts. Try again in 15 minutes.'
    });
  },
  skipSuccessfulRequests: true
});

const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100
});

module.exports = { loginLimiter, apiLimiter };
