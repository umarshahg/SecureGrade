const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({
      filename: 'audit.log',
      maxsize: 5242880,
      maxFiles: 5
    })
  ]
});

const log = async (event, data) => {
  logger.info({ event, ...data });
};

module.exports = { log };
