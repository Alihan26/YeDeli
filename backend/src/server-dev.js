const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');

const app = express();

// Security middleware
app.use(helmet());
app.use(compression());

// CORS configuration
app.use(cors({
  origin: "http://localhost:3000",
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    mode: 'development',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    message: 'YeDeli Backend running in development mode (no database)'
  });
});

// Mock API endpoints for development
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'Backend is working! This is a mock endpoint.',
    data: {
      timestamp: new Date().toISOString(),
      mode: 'development'
    }
  });
});

// Mock authentication endpoint
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'Email and password are required',
        code: 'MISSING_CREDENTIALS'
      }
    });
  }
  
  // Mock successful login
  res.json({
    success: true,
    message: 'Login successful (mock)',
    data: {
      user: {
        id: 'mock-user-123',
        email: email,
        name: 'Mock User',
        role: 'buyer',
        isVerified: true
      },
      tokens: {
        accessToken: 'mock-access-token-' + Date.now(),
        refreshToken: 'mock-refresh-token-' + Date.now()
      }
    }
  });
});

// Mock user registration
app.post('/api/auth/register', (req, res) => {
  const { email, password, name, role } = req.body;
  
  if (!email || !password || !name || !role) {
    return res.status(400).json({
      success: false,
      error: {
        message: 'All fields are required',
        code: 'MISSING_FIELDS'
      }
    });
  }
  
  // Mock successful registration
  res.status(201).json({
    success: true,
    message: 'User registered successfully (mock)',
    data: {
      user: {
        id: 'mock-user-' + Date.now(),
        email: email,
        name: name,
        role: role,
        isVerified: false
      },
      tokens: {
        accessToken: 'mock-access-token-' + Date.now(),
        refreshToken: 'mock-refresh-token-' + Date.now()
      }
    }
  });
});

// Mock dishes endpoint
app.get('/api/dishes', (req, res) => {
  res.json({
    success: true,
    data: {
      dishes: [
        {
          id: 'mock-dish-1',
          name: 'Paella Valenciana',
          description: 'Authentic Spanish paella with saffron rice and seafood',
          price: 28.50,
          cuisine: 'spanish',
          cookName: 'Maria Garcia',
          isActive: true
        },
        {
          id: 'mock-dish-2',
          name: 'Pasta Carbonara',
          description: 'Classic Italian pasta with eggs, cheese, and pancetta',
          price: 22.00,
          cuisine: 'italian',
          cookName: 'Giuseppe Rossi',
          isActive: true
        }
      ]
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    message: 'This is a development server. Check the README for setup instructions.'
  });
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log('🚀 YeDeli Development Backend Server running on port', PORT);
  console.log('📱 Health check: http://localhost:' + PORT + '/health');
  console.log('🔗 Test endpoint: http://localhost:' + PORT + '/api/test');
  console.log('⚠️  This is DEVELOPMENT MODE - no database required');
  console.log('');
  console.log('To run with full database:');
  console.log('1. Install PostgreSQL and Redis');
  console.log('2. Run: npm start (instead of npm run dev)');
});

module.exports = app;
