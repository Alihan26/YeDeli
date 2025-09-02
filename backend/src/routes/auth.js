const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const { getPool } = require('../database/connection');
const { generateToken, generateRefreshToken, verifyToken } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { logger } = require('../utils/logger');

const router = express.Router();

// Validation middleware
const validateRegistration = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters long'),
  body('role').isIn(['buyer', 'cook']).withMessage('Role must be either buyer or cook'),
  body('phone').optional().isMobilePhone().withMessage('Please provide a valid phone number')
];

const validateLogin = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required')
];

// User registration
router.post('/register', validateRegistration, asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        details: errors.array()
      }
    });
  }

  const { email, password, name, role, phone, address } = req.body;
  const pool = getPool();

  try {
    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: {
          message: 'User with this email already exists',
          code: 'USER_EXISTS'
        }
      });
    }

    // Hash password
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const newUser = await pool.query(
      `INSERT INTO users (email, password_hash, name, role, phone, address, is_verified)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, email, name, role, phone, address, is_verified, created_at`,
      [email, passwordHash, name, role, phone, address, false]
    );

    const user = newUser.rows[0];

    // Create user preferences
    await pool.query(
      `INSERT INTO user_preferences (user_id, dietary_restrictions, favorite_cuisines, max_pickup_distance, notifications_enabled, language, currency)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [user.id, [], [], 5.0, true, 'en', 'CHF']
    );

    // Generate tokens
    const accessToken = generateToken(user);
    const refreshToken = generateRefreshToken(user);

    // Store refresh token in database (optional - for token revocation)
    await pool.query(
      'UPDATE users SET refresh_token = $1 WHERE id = $2',
      [refreshToken, user.id]
    );

    logger.info('User registered successfully', { userId: user.id, email: user.email, role: user.role });

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          phone: user.phone,
          address: user.address,
          isVerified: user.is_verified
        },
        tokens: {
          accessToken,
          refreshToken
        }
      }
    });

  } catch (error) {
    logger.error('User registration failed', { error: error.message, email });
    throw error;
  }
}));

// User login
router.post('/login', validateLogin, asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        details: errors.array()
      }
    });
  }

  const { email, password } = req.body;
  const pool = getPool();

  try {
    // Find user by email
    const user = await pool.query(
      `SELECT id, email, password_hash, name, role, phone, address, is_verified, cook_bio, cook_rating, cook_total_orders, cook_is_active
       FROM users WHERE email = $1`,
      [email]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS'
        }
      });
    }

    const userData = user.rows[0];

    // Check password
    const isPasswordValid = await bcrypt.compare(password, userData.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS'
        }
      });
    }

    // Check if user is active (for cooks)
    if (userData.role === 'cook' && !userData.cook_is_active) {
      return res.status(403).json({
        success: false,
        error: {
          message: 'Your cook account is currently inactive',
          code: 'ACCOUNT_INACTIVE'
        }
      });
    }

    // Generate tokens
    const accessToken = generateToken(userData);
    const refreshToken = generateRefreshToken(userData);

    // Update refresh token in database
    await pool.query(
      'UPDATE users SET refresh_token = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [refreshToken, userData.id]
    );

    logger.info('User logged in successfully', { userId: userData.id, email: userData.email, role: userData.role });

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: userData.id,
          email: userData.email,
          name: userData.name,
          role: userData.role,
          phone: userData.phone,
          address: userData.address,
          isVerified: userData.is_verified,
          cookBio: userData.cook_bio,
          cookRating: userData.cook_rating,
          cookTotalOrders: userData.cook_total_orders,
          cookIsActive: userData.cook_is_active
        },
        tokens: {
          accessToken,
          refreshToken
        }
      }
    });

  } catch (error) {
    logger.error('User login failed', { error: error.message, email });
    throw error;
  }
}));

// Token refresh
router.post('/refresh', asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Refresh token is required',
        code: 'MISSING_REFRESH_TOKEN'
      }
    });
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET || 'your-secret-key-change-in-production');
    
    if (decoded.type !== 'refresh') {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid refresh token',
          code: 'INVALID_REFRESH_TOKEN'
        }
      });
    }

    const pool = getPool();
    
    // Get user data
    const user = await pool.query(
      'SELECT id, email, name, role, phone, address, is_verified FROM users WHERE id = $1 AND refresh_token = $2',
      [decoded.id, refreshToken]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid refresh token',
          code: 'INVALID_REFRESH_TOKEN'
        }
      });
    }

    const userData = user.rows[0];

    // Generate new tokens
    const newAccessToken = generateToken(userData);
    const newRefreshToken = generateRefreshToken(userData);

    // Update refresh token in database
    await pool.query(
      'UPDATE users SET refresh_token = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [newRefreshToken, userData.id]
    );

    logger.info('Token refreshed successfully', { userId: userData.id });

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        tokens: {
          accessToken: newAccessToken,
          refreshToken: newRefreshToken
        }
      }
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Refresh token expired',
          code: 'REFRESH_TOKEN_EXPIRED'
        }
      });
    }

    logger.error('Token refresh failed', { error: error.message });
    throw error;
  }
}));

// Logout
router.post('/logout', verifyToken, asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const pool = getPool();

  try {
    // Clear refresh token
    await pool.query(
      'UPDATE users SET refresh_token = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = $1',
      [userId]
    );

    logger.info('User logged out successfully', { userId });

    res.json({
      success: true,
      message: 'Logout successful'
    });

  } catch (error) {
    logger.error('Logout failed', { error: error.message, userId });
    throw error;
  }
}));

// Get current user
router.get('/me', verifyToken, asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const pool = getPool();

  try {
    const user = await pool.query(
      `SELECT id, email, name, role, phone, address, is_verified, cook_bio, cook_rating, cook_total_orders, cook_is_active, created_at
       FROM users WHERE id = $1`,
      [userId]
    );

    if (user.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          message: 'User not found',
          code: 'USER_NOT_FOUND'
        }
      });
    }

    const userData = user.rows[0];

    res.json({
      success: true,
      data: {
        user: {
          id: userData.id,
          email: userData.email,
          name: userData.name,
          role: userData.role,
          phone: userData.phone,
          address: userData.address,
          isVerified: userData.is_verified,
          cookBio: userData.cook_bio,
          cookRating: userData.cook_rating,
          cookTotalOrders: userData.cook_total_orders,
          cookIsActive: userData.cook_is_active,
          createdAt: userData.created_at
        }
      }
    });

  } catch (error) {
    logger.error('Get current user failed', { error: error.message, userId });
    throw error;
  }
}));

// Password reset request
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email')
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        details: errors.array()
      }
    });
  }

  const { email } = req.body;
  const pool = getPool();

  try {
    // Check if user exists
    const user = await pool.query(
      'SELECT id, name FROM users WHERE email = $1',
      [email]
    );

    if (user.rows.length === 0) {
      // Don't reveal if user exists or not
      return res.json({
        success: true,
        message: 'If an account with that email exists, a password reset link has been sent'
      });
    }

    // Generate reset token (in production, send email)
    const resetToken = generateToken({ id: user.rows[0].id, type: 'reset' }, '1h');
    
    // Store reset token in database
    await pool.query(
      'UPDATE users SET reset_token = $1, reset_token_expires = CURRENT_TIMESTAMP + INTERVAL \'1 hour\' WHERE id = $2',
      [resetToken, user.rows[0].id]
    );

    logger.info('Password reset requested', { userId: user.rows[0].id, email });

    res.json({
      success: true,
      message: 'If an account with that email exists, a password reset link has been sent'
    });

  } catch (error) {
    logger.error('Password reset request failed', { error: error.message, email });
    throw error;
  }
}));

// Reset password
router.post('/reset-password', [
  body('token').notEmpty().withMessage('Reset token is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long')
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        details: errors.array()
      }
    });
  }

  const { token, password } = req.body;
  const pool = getPool();

  try {
    // Verify reset token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-in-production');
    
    if (decoded.type !== 'reset') {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Invalid reset token',
          code: 'INVALID_RESET_TOKEN'
        }
      });
    }

    // Check if token is still valid in database
    const user = await pool.query(
      'SELECT id FROM users WHERE id = $1 AND reset_token = $2 AND reset_token_expires > CURRENT_TIMESTAMP',
      [decoded.id, token]
    );

    if (user.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Reset token is invalid or expired',
          code: 'INVALID_RESET_TOKEN'
        }
      });
    }

    // Hash new password
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Update password and clear reset token
    await pool.query(
      'UPDATE users SET password_hash = $1, reset_token = NULL, reset_token_expires = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [passwordHash, decoded.id]
    );

    logger.info('Password reset successfully', { userId: decoded.id });

    res.json({
      success: true,
      message: 'Password reset successfully'
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Reset token expired',
          code: 'RESET_TOKEN_EXPIRED'
        }
      });
    }

    logger.error('Password reset failed', { error: error.message });
    throw error;
  }
}));

module.exports = router;
