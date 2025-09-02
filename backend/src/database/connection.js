const { Pool } = require('pg');
const { logger } = require('../utils/logger');

// Database configuration
const dbConfig = {
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'yedeli',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection could not be established
  maxUses: 7500, // Close (and replace) a connection after it has been used 7500 times
};

// Create connection pool
const pool = new Pool(dbConfig);

// Handle pool errors
pool.on('error', (err) => {
  logger.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Test database connection
async function testConnection() {
  try {
    const client = await pool.connect();
    logger.info('✅ PostgreSQL database connected successfully');
    client.release();
    return true;
  } catch (error) {
    logger.error('❌ Failed to connect to PostgreSQL:', error.message);
    return false;
  }
}

// Connect to database
async function connectDB() {
  try {
    await testConnection();
    
    // Create tables if they don't exist
    await createTables();
    
    logger.info('🚀 Database initialization completed');
  } catch (error) {
    logger.error('Database initialization failed:', error);
    throw error;
  }
}

// Create database tables
async function createTables() {
  const client = await pool.connect();
  
  try {
    // Ensure pgcrypto extension is available for gen_random_uuid()
    await client.query(`CREATE EXTENSION IF NOT EXISTS pgcrypto;`);
    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        address TEXT,
        profile_image_url TEXT,
        role VARCHAR(20) NOT NULL DEFAULT 'buyer' CHECK (role IN ('buyer', 'cook', 'admin')),
        is_verified BOOLEAN DEFAULT FALSE,
        cook_bio TEXT,
        cook_rating DECIMAL(3,2) DEFAULT 0.00,
        cook_total_orders INTEGER DEFAULT 0,
        cook_is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // User preferences table
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_preferences (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        dietary_restrictions TEXT[],
        favorite_cuisines TEXT[],
        max_pickup_distance DECIMAL(5,2) DEFAULT 5.0,
        notifications_enabled BOOLEAN DEFAULT TRUE,
        language VARCHAR(10) DEFAULT 'en',
        currency VARCHAR(3) DEFAULT 'CHF',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Cuisines table
    await client.query(`
      CREATE TABLE IF NOT EXISTS cuisines (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(100) UNIQUE NOT NULL,
        display_name VARCHAR(100) NOT NULL,
        icon VARCHAR(50),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Dishes table
    await client.query(`
      CREATE TABLE IF NOT EXISTS dishes (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        cook_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        image_url TEXT,
        cuisine_id UUID REFERENCES cuisines(id),
        dietary_tags TEXT[],
        ingredients TEXT[],
        allergens TEXT[],
        preparation_time INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Batches table
    await client.query(`
      CREATE TABLE IF NOT EXISTS batches (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        dish_id UUID REFERENCES dishes(id) ON DELETE CASCADE,
        cook_id UUID REFERENCES users(id) ON DELETE CASCADE,
        scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
        pickup_date TIMESTAMP WITH TIME ZONE NOT NULL,
        capacity INTEGER NOT NULL,
        current_orders INTEGER DEFAULT 0,
        cutoff_date TIMESTAMP WITH TIME ZONE NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'ready', 'completed', 'cancelled')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Orders table
    await client.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
        dish_id UUID REFERENCES dishes(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        total_price DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
        pickup_code VARCHAR(10) UNIQUE,
        order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        pickup_date TIMESTAMP WITH TIME ZONE,
        pickup_time VARCHAR(20),
        special_instructions TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Payments table
    await client.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        amount DECIMAL(10,2) NOT NULL,
        currency VARCHAR(3) DEFAULT 'CHF',
        payment_method VARCHAR(50) NOT NULL,
        stripe_payment_intent_id VARCHAR(255),
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'succeeded', 'failed', 'refunded')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Reviews table
    await client.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        cook_id UUID REFERENCES users(id) ON DELETE CASCADE,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create indexes for better performance
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
      CREATE INDEX IF NOT EXISTS idx_dishes_cook_id ON dishes(cook_id);
      CREATE INDEX IF NOT EXISTS idx_dishes_cuisine_id ON dishes(cuisine_id);
      CREATE INDEX IF NOT EXISTS idx_batches_cook_id ON batches(cook_id);
      CREATE INDEX IF NOT EXISTS idx_batches_status ON batches(status);
      CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
      CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
      CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
      CREATE INDEX IF NOT EXISTS idx_reviews_cook_id ON reviews(cook_id);
    `);

    logger.info('✅ Database tables created successfully');
  } catch (error) {
    logger.error('❌ Failed to create tables:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Get database pool
function getPool() {
  return pool;
}

// Close database connections
async function closeDB() {
  try {
    await pool.end();
    logger.info('✅ Database connections closed');
  } catch (error) {
    logger.error('❌ Error closing database connections:', error);
  }
}

module.exports = {
  connectDB,
  closeDB,
  getPool,
  testConnection
};
