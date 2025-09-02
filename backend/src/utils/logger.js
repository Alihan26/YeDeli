const winston = require('winston');
const path = require('path');

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
    let log = `${timestamp} [${level.toUpperCase()}]: ${message}`;
    
    if (Object.keys(meta).length > 0) {
      log += ` ${JSON.stringify(meta)}`;
    }
    
    if (stack) {
      log += `\n${stack}`;
    }
    
    return log;
  })
);

// Create logger instance
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: { service: 'yedeli-backend' },
  transports: [
    // Console transport
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    
    // File transport for errors
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    
    // File transport for all logs
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/combined.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 5
    })
  ],
  
  // Handle uncaught exceptions
  exceptionHandlers: [
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/exceptions.log')
    })
  ],
  
  // Handle unhandled rejections
  rejectionHandlers: [
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/rejections.log')
    })
  ]
});

// Create logs directory if it doesn't exist
const fs = require('fs');
const logsDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Preserve original methods to avoid recursion when decorating
const originalInfo = logger.info.bind(logger);
const originalWarn = logger.warn.bind(logger);
const originalError = logger.error.bind(logger);
const originalDebug = logger.debug.bind(logger);

// Add custom helper methods and decorate common levels
logger.startup = (message, meta = {}) => {
  originalInfo(`🚀 ${message}`, meta);
};

logger.success = (message, meta = {}) => {
  originalInfo(`✅ ${message}`, meta);
};

logger.warning = (message, meta = {}) => {
  originalWarn(`⚠️ ${message}`, meta);
};

logger.info = (message, meta = {}) => {
  originalInfo(`ℹ️ ${message}`, meta);
};

logger.warn = (message, meta = {}) => {
  originalWarn(`⚠️ ${message}`, meta);
};

logger.error = (message, meta = {}) => {
  originalError(`❌ ${message}`, meta);
};

logger.debug = (message, meta = {}) => {
  originalDebug(`🔍 ${message}`, meta);
};

// Request logging middleware
const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.get('User-Agent')
    };
    
    if (res.statusCode >= 400) {
      logger.warning('HTTP Request', logData);
    } else {
      logger.debug('HTTP Request', logData);
    }
  });
  
  next();
};

// Error logging middleware
const errorLogger = (error, req, res, next) => {
  logger.error('Unhandled Error', {
    error: error.message,
    stack: error.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  
  next(error);
};

module.exports = {
  logger,
  requestLogger,
  errorLogger
};
