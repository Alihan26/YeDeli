# YeDeli Backend API

A production-ready Node.js/Express backend for the YeDeli marketplace platform, built with security, scalability, and maintainability in mind.

## 🚀 Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **Database**: PostgreSQL with connection pooling and automatic table creation
- **Caching**: Redis for session management and real-time features
- **Real-time Communication**: Socket.IO for live updates and notifications
- **Security**: Helmet, CORS, rate limiting, input validation
- **Logging**: Winston-based logging with file rotation
- **Error Handling**: Comprehensive error handling with custom error codes
- **File Uploads**: Support for image uploads with AWS S3 integration
- **Payment Processing**: Stripe integration for secure payments
- **API Documentation**: RESTful API design with consistent response formats

## 🏗️ Architecture

```
src/
├── database/          # Database connections and migrations
├── middleware/        # Authentication, validation, error handling
├── routes/           # API route handlers
├── utils/            # Utility functions and helpers
├── server.js         # Main server file
└── logs/             # Application logs
```

## 🛠️ Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **Authentication**: JWT
- **Validation**: express-validator
- **Logging**: Winston
- **Real-time**: Socket.IO
- **Payments**: Stripe
- **File Storage**: AWS S3
- **Containerization**: Docker

## 📋 Prerequisites

- Node.js 18+ 
- PostgreSQL 15+
- Redis 7+

## 🚀 Quick Start

### 1. Clone and Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Setup

```bash
# Copy environment template
cp env.example .env

# Edit .env with your configuration
nano .env
```

### 3. Database Setup (Local Installation)

```bash
# Install PostgreSQL
brew install postgresql  # macOS
sudo apt-get install postgresql postgresql-contrib  # Ubuntu

# Install Redis
brew install redis  # macOS
sudo apt-get install redis-server  # Ubuntu

# Start services
brew services start postgresql  # macOS
brew services start redis       # macOS
```

### 4. Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE yedeli;
\q
```

### 5. Start the Server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3001`

### Dev vs Full mode

- `npm run dev` runs a lightweight development server from `src/server-dev.js` with mock endpoints. This mode does not require PostgreSQL or Redis and is ideal for quickly testing the iOS app UI.
- `npm start` runs the full server from `src/server.js`, connects to your locally installed PostgreSQL and Redis, and initializes the database schema automatically (including the `pgcrypto` extension for `gen_random_uuid()`).
- Some feature routes (`users`, `dishes`, `batches`, `orders`, `payments`, `notifications`) are currently provided as minimal stubs. Expand them as you implement each feature.

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment (development/production) | `development` |
| `PORT` | Server port | `3001` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `yedeli` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password | `password` |
| `REDIS_HOST` | Redis host | `localhost` |
| `REDIS_PORT` | Redis port | `6379` |
| `JWT_SECRET` | JWT signing secret | `your-secret-key` |
| `STRIPE_SECRET_KEY` | Stripe secret key | - |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |

### Database Configuration

The backend automatically creates all necessary tables on startup and ensures `pgcrypto` is available for UUID generation:

- **users**: User accounts and profiles
- **user_preferences**: User preferences and settings
- **cuisines**: Available cuisine types
- **dishes**: Cook dishes and menu items
- **batches**: Batch scheduling and availability
- **orders**: Customer orders and status
- **payments**: Payment processing records
- **reviews**: User reviews and ratings

## 📚 API Documentation

### Authentication Endpoints

#### POST `/api/auth/register`
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "role": "buyer",
  "phone": "+41791234567",
  "address": "Zurich, Switzerland"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": { ... },
    "tokens": {
      "accessToken": "...",
      "refreshToken": "..."
    }
  }
}
```

#### POST `/api/auth/login`
Authenticate user and receive access tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### POST `/api/auth/refresh`
Refresh expired access token.

**Request Body:**
```json
{
  "refreshToken": "..."
}
```

#### POST `/api/auth/logout`
Logout user and invalidate tokens.

**Headers:**
```
Authorization: Bearer <accessToken>
```

#### GET `/api/auth/me`
Get current user profile.

**Headers:**
```
Authorization: Bearer <accessToken>
```

### User Management

#### GET `/api/users/:id`
Get user profile by ID.

#### PUT `/api/users/:id`
Update user profile.

#### DELETE `/api/users/:id`
Delete user account.

### Dish Management (Cook Features)

#### GET `/api/dishes`
Get all dishes (with filtering).

#### POST `/api/dishes`
Create new dish (cook only).

#### GET `/api/dishes/:id`
Get dish details.

#### PUT `/api/dishes/:id`
Update dish (owner only).

#### DELETE `/api/dishes/:id`
Delete dish (owner only).

### Batch Management (Cook Features)

#### GET `/api/batches`
Get all batches (with filtering).

#### POST `/api/batches`
Create new batch (cook only).

#### GET `/api/batches/:id`
Get batch details.

#### PUT `/api/batches/:id`
Update batch (owner only).

#### DELETE `/api/batches/:id`
Delete batch (owner only).

### Order Management

#### GET `/api/orders`
Get user orders.

#### POST `/api/orders`
Create new order.

#### GET `/api/orders/:id`
Get order details.

#### PUT `/api/orders/:id`
Update order status.

### Payment Processing

#### POST `/api/payments/create-intent`
Create Stripe payment intent.

#### POST `/api/payments/confirm`
Confirm payment.

#### POST `/api/payments/refund`
Process refund.

## 🔐 Authentication & Authorization

### JWT Tokens

- **Access Token**: Valid for 24 hours
- **Refresh Token**: Valid for 7 days
- **Reset Token**: Valid for 1 hour

### Role-Based Access Control

- **buyer**: Can place orders, view dishes, manage profile
- **cook**: Can create dishes, manage batches, view orders
- **admin**: Full system access

### Protected Routes

Protected routes require the `Authorization` header:
```
Authorization: Bearer <accessToken>
```

### Ownership Validation

Resources are protected by ownership validation:
- Users can only access their own data
- Cooks can only manage their own dishes and batches
- Admins have access to all resources

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'buyer',
  is_verified BOOLEAN DEFAULT FALSE,
  cook_bio TEXT,
  cook_rating DECIMAL(3,2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Dishes Table
```sql
CREATE TABLE dishes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cook_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  cuisine_id UUID REFERENCES cuisines(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## 📝 Logging

Logs are stored in the `logs/` directory:
- `combined.log`: All log levels
- `error.log`: Error-level logs only
- `exceptions.log`: Uncaught exceptions
- `rejections.log`: Unhandled promise rejections

## 🚀 Deployment

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure production database
- [ ] Set secure JWT secret
- [ ] Configure SSL/TLS
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Set up CI/CD pipeline

<!-- Docker deployment removed per project choice to run locally for now. -->

## 🔒 Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: API request throttling
- **Input Validation**: Request data sanitization
- **SQL Injection Protection**: Parameterized queries
- **XSS Protection**: Content Security Policy
- **JWT Security**: Secure token handling

## 📊 Monitoring & Health Checks

### Health Endpoint
```
GET /health
```

Returns server status, uptime, and environment information.

### Logging
- Request/response logging
- Error tracking
- Performance monitoring
- User activity tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Built with ❤️ for the YeDeli marketplace platform**
