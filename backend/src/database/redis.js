const redis = require('redis');
const { logger } = require('../utils/logger');

let client = null;

// Node-redis v4 uses a URL or options without retry_strategy. Build URL for simplicity.
const redisUrl = process.env.REDIS_PASSWORD
  ? `redis://:${process.env.REDIS_PASSWORD}@${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}/${process.env.REDIS_DB || 0}`
  : `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}/${process.env.REDIS_DB || 0}`;

// Connect to Redis
async function connectRedis() {
  try {
    client = redis.createClient({ url: redisUrl });
    
    client.on('connect', () => {
      logger.info('✅ Redis connected successfully');
    });
    
    client.on('ready', () => {
      logger.info('🚀 Redis ready for operations');
    });
    
    client.on('error', (err) => {
      logger.error('❌ Redis error:', err);
    });
    
    client.on('end', () => {
      logger.info('Redis connection ended');
    });
    
    await client.connect();
    
    // Test connection
    await client.ping();
    logger.info('✅ Redis ping successful');
    
  } catch (error) {
    logger.error('❌ Failed to connect to Redis:', error.message);
    // Don't throw error - Redis is optional for development
    if (process.env.NODE_ENV === 'production') {
      throw error;
    }
  }
}

// Get Redis client
function getClient() {
  return client;
}

// Set key-value pair
async function set(key, value, expireSeconds = null) {
  try {
    if (!client) return false;
    
    if (expireSeconds) {
      await client.setEx(key, expireSeconds, JSON.stringify(value));
    } else {
      await client.set(key, JSON.stringify(value));
    }
    return true;
  } catch (error) {
    logger.error('Redis set error:', error);
    return false;
  }
}

// Get value by key
async function get(key) {
  try {
    if (!client) return null;
    
    const value = await client.get(key);
    return value ? JSON.parse(value) : null;
  } catch (error) {
    logger.error('Redis get error:', error);
    return null;
  }
}

// Delete key
async function del(key) {
  try {
    if (!client) return false;
    
    await client.del(key);
    return true;
  } catch (error) {
    logger.error('Redis del error:', error);
    return false;
  }
}

// Set hash field
async function hset(key, field, value) {
  try {
    if (!client) return false;
    
    await client.hSet(key, field, JSON.stringify(value));
    return true;
  } catch (error) {
    logger.error('Redis hset error:', error);
    return false;
  }
}

// Get hash field
async function hget(key, field) {
  try {
    if (!client) return null;
    
    const value = await client.hGet(key, field);
    return value ? JSON.parse(value) : null;
  } catch (error) {
    logger.error('Redis hget error:', error);
    return null;
  }
}

// Get all hash fields
async function hgetall(key) {
  try {
    if (!client) return null;
    
    const hash = await client.hGetAll(key);
    const result = {};
    
    for (const [field, value] of Object.entries(hash)) {
      try {
        result[field] = JSON.parse(value);
      } catch {
        result[field] = value;
      }
    }
    
    return result;
  } catch (error) {
    logger.error('Redis hgetall error:', error);
    return null;
  }
}

// Add to sorted set
async function zadd(key, score, member) {
  try {
    if (!client) return false;
    
    await client.zAdd(key, { score, value: member });
    return true;
  } catch (error) {
    logger.error('Redis zadd error:', error);
    return false;
  }
}

// Get sorted set range
async function zrange(key, start, stop, withScores = false) {
  try {
    if (!client) return [];
    
    if (withScores) {
      return await client.zRangeWithScores(key, start, stop);
    } else {
      return await client.zRange(key, start, stop);
    }
  } catch (error) {
    logger.error('Redis zrange error:', error);
    return [];
  }
}

// Publish message to channel
async function publish(channel, message) {
  try {
    if (!client) return false;
    
    await client.publish(channel, JSON.stringify(message));
    return true;
  } catch (error) {
    logger.error('Redis publish error:', error);
    return false;
  }
}

// Subscribe to channel
async function subscribe(channel, callback) {
  try {
    if (!client) return false;
    
    const subscriber = client.duplicate();
    await subscriber.connect();
    
    await subscriber.subscribe(channel, (message) => {
      try {
        const parsedMessage = JSON.parse(message);
        callback(parsedMessage);
      } catch {
        callback(message);
      }
    });
    
    return subscriber;
  } catch (error) {
    logger.error('Redis subscribe error:', error);
    return false;
  }
}

// Close Redis connection
async function closeRedis() {
  try {
    if (client) {
      await client.quit();
      logger.info('✅ Redis connection closed');
    }
  } catch (error) {
    logger.error('❌ Error closing Redis connection:', error);
  }
}

module.exports = {
  connectRedis,
  closeRedis,
  getClient,
  set,
  get,
  del,
  hset,
  hget,
  hgetall,
  zadd,
  zrange,
  publish,
  subscribe
};
