const jwt = require('jsonwebtoken');
const { getPool } = require('../database/connection');
const { logger } = require('../utils/logger');

// JWT secret from environment variables
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Verify JWT token
const verifyToken = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        error: 'Access denied. No token provided.',
        code: 'NO_TOKEN'
      });
    }
    
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    logger.warning('Token verification failed', { error: error.message });
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token expired. Please login again.',
        code: 'TOKEN_EXPIRED'
      });
    }
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid token. Please login again.',
        code: 'INVALID_TOKEN'
      });
    }
    
    return res.status(401).json({
      error: 'Invalid token.',
      code: 'INVALID_TOKEN'
    });
  }
};

// Check if user has required role
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required.',
        code: 'AUTH_REQUIRED'
      });
    }
    
    const userRole = req.user.role;
    
    if (Array.isArray(roles)) {
      if (!roles.includes(userRole)) {
        return res.status(403).json({
          error: 'Insufficient permissions.',
          code: 'INSUFFICIENT_PERMISSIONS',
          required: roles,
          current: userRole
        });
      }
    } else {
      if (userRole !== roles) {
        return res.status(403).json({
          error: 'Insufficient permissions.',
          code: 'INSUFFICIENT_PERMISSIONS',
          required: roles,
          current: userRole
        });
      }
    }
    
    next();
  };
};

// Check if user owns the resource or is admin
const requireOwnership = (resourceType) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Authentication required.',
          code: 'AUTH_REQUIRED'
        });
      }
      
      const userId = req.user.id;
      const userRole = req.user.role;
      
      // Admin can access everything
      if (userRole === 'admin') {
        return next();
      }
      
      // Get resource ID from request
      const resourceId = req.params.id || req.body.id;
      
      if (!resourceId) {
        return res.status(400).json({
          error: 'Resource ID required.',
          code: 'MISSING_RESOURCE_ID'
        });
      }
      
      const pool = getPool();
      let query;
      let params;
      
      switch (resourceType) {
        case 'user':
          query = 'SELECT id FROM users WHERE id = $1';
          params = [resourceId];
          break;
          
        case 'dish':
          query = 'SELECT cook_id FROM dishes WHERE id = $1';
          params = [resourceId];
          break;
          
        case 'batch':
          query = 'SELECT cook_id FROM batches WHERE id = $1';
          params = [resourceId];
          break;
          
        case 'order':
          query = 'SELECT user_id, cook_id FROM orders WHERE id = $1';
          params = [resourceId];
          break;
          
        default:
          return res.status(400).json({
            error: 'Invalid resource type.',
            code: 'INVALID_RESOURCE_TYPE'
          });
      }
      
      const result = await pool.query(query, params);
      
      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Resource not found.',
          code: 'RESOURCE_NOT_FOUND'
        });
      }
      
      const resource = result.rows[0];
      
      // Check ownership
      let hasAccess = false;
      
      switch (resourceType) {
        case 'user':
          hasAccess = resource.id === userId;
          break;
          
        case 'dish':
          hasAccess = resource.cook_id === userId;
          break;
          
        case 'batch':
          hasAccess = resource.cook_id === userId;
          break;
          
        case 'order':
          hasAccess = resource.user_id === userId || resource.cook_id === userId;
          break;
      }
      
      if (!hasAccess) {
        return res.status(403).json({
          error: 'Access denied. You do not own this resource.',
          code: 'ACCESS_DENIED'
        });
      }
      
      next();
    } catch (error) {
      logger.error('Ownership check failed', { error: error.message });
      return res.status(500).json({
        error: 'Internal server error.',
        code: 'INTERNAL_ERROR'
      });
    }
  };
};

// Generate JWT token
const generateToken = (user) => {
  const payload = {
    id: user.id,
    email: user.email,
    role: user.role,
    isVerified: user.is_verified
  };
  
  const options = {
    expiresIn: '24h' // Token expires in 24 hours
  };
  
  return jwt.sign(payload, JWT_SECRET, options);
};

// Generate refresh token
const generateRefreshToken = (user) => {
  const payload = {
    id: user.id,
    type: 'refresh'
  };
  
  const options = {
    expiresIn: '7d' // Refresh token expires in 7 days
  };
  
  return jwt.sign(payload, JWT_SECRET, options);
};

// Optional authentication (doesn't fail if no token)
const optionalAuth = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (token) {
      const decoded = jwt.verify(token, JWT_SECRET);
      req.user = decoded;
    }
    
    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
};

module.exports = {
  verifyToken,
  requireRole,
  requireOwnership,
  generateToken,
  generateRefreshToken,
  optionalAuth
};
