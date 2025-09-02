const { logger } = require('../utils/logger');

// Custom error class
class AppError extends Error {
  constructor(message, statusCode, errorCode = null) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

// Error handler middleware
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;
  
  // Log error
  logger.error('Error occurred', {
    error: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.id
  });
  
  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new AppError(message, 404, 'RESOURCE_NOT_FOUND');
  }
  
  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    const message = `Duplicate field value: ${field}`;
    error = new AppError(message, 400, 'DUPLICATE_FIELD');
  }
  
  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = new AppError(message, 400, 'VALIDATION_ERROR');
  }
  
  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new AppError(message, 401, 'INVALID_TOKEN');
  }
  
  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new AppError(message, 401, 'TOKEN_EXPIRED');
  }
  
  // PostgreSQL errors
  if (err.code === '23505') { // unique_violation
    const message = 'Duplicate entry';
    error = new AppError(message, 400, 'DUPLICATE_ENTRY');
  }
  
  if (err.code === '23503') { // foreign_key_violation
    const message = 'Referenced resource not found';
    error = new AppError(message, 400, 'REFERENCE_ERROR');
  }
  
  if (err.code === '23502') { // not_null_violation
    const message = 'Required field missing';
    error = new AppError(message, 400, 'MISSING_FIELD');
  }
  
  // Rate limiting errors
  if (err.status === 429) {
    const message = 'Too many requests';
    error = new AppError(message, 429, 'RATE_LIMIT_EXCEEDED');
  }
  
  // File upload errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    const message = 'File too large';
    error = new AppError(message, 400, 'FILE_TOO_LARGE');
  }
  
  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    const message = 'Unexpected file field';
    error = new AppError(message, 400, 'UNEXPECTED_FILE');
  }
  
  // Stripe errors
  if (err.type === 'StripeCardError') {
    const message = err.message;
    error = new AppError(message, 400, 'PAYMENT_ERROR');
  }
  
  if (err.type === 'StripeInvalidRequestError') {
    const message = 'Invalid payment request';
    error = new AppError(message, 400, 'INVALID_PAYMENT_REQUEST');
  }
  
  // Default error
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';
  const errorCode = error.errorCode || 'INTERNAL_ERROR';
  
  // Don't leak error details in production
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  res.status(statusCode).json({
    success: false,
    error: {
      message: isDevelopment ? message : 'Something went wrong',
      code: errorCode,
      ...(isDevelopment && { stack: err.stack })
    },
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  });
};

// Async error wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Not found handler
const notFound = (req, res, next) => {
  const error = new AppError(`Route ${req.originalUrl} not found`, 404, 'ROUTE_NOT_FOUND');
  next(error);
};

// Validation error handler
const handleValidationError = (err) => {
  const errors = Object.values(err.errors).map(val => val.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new AppError(message, 400, 'VALIDATION_ERROR');
};

// Duplicate key error handler
const handleDuplicateKeyError = (err) => {
  const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
  const message = `Duplicate field value: ${value}. Please use another value!`;
  return new AppError(message, 400, 'DUPLICATE_FIELD');
};

// Cast error handler
const handleCastError = (err) => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400, 'INVALID_ID');
};

// JWT error handler
const handleJWTError = () => {
  return new AppError('Invalid token. Please log in again!', 401, 'INVALID_TOKEN');
};

// JWT expired error handler
const handleJWTExpiredError = () => {
  return new AppError('Your token has expired! Please log in again.', 401, 'TOKEN_EXPIRED');
};

module.exports = {
  AppError,
  errorHandler,
  asyncHandler,
  notFound,
  handleValidationError,
  handleDuplicateKeyError,
  handleCastError,
  handleJWTError,
  handleJWTExpiredError
};
