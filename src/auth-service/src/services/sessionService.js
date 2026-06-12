const redis = require('../config/redis');

const create = async (userId, token) => {
  await redis.setEx(`session:${userId}`, 900, token);
};

const destroy = async (userId) => {
  await redis.del(`session:${userId}`);
};

const blacklist = async (token) => {
  await redis.setEx(`blacklist:${token}`, 900, 'true');
};

const isBlacklisted = async (token) => {
  const result = await redis.get(`blacklist:${token}`);
  return result === 'true';
};

module.exports = { create, destroy, blacklist, isBlacklisted };
