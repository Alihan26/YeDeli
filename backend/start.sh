#!/bin/bash

# YeDeli Backend Startup Script

echo "🚀 Starting YeDeli Backend..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    if [ -f env.example ]; then
        cp env.example .env
        echo "✅ .env file created from template. Please edit it with your configuration."
        echo "📝 Edit .env file and run this script again."
        exit 1
    else
        echo "❌ env.example not found. Please create .env file manually."
        exit 1
    fi
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies."
        exit 1
    fi
    echo "✅ Dependencies installed successfully."
fi

# Check if PostgreSQL is running (optional check)
if command -v pg_isready &> /dev/null; then
    if pg_isready -h localhost -p 5432 &> /dev/null; then
        echo "✅ PostgreSQL is running"
    else
        echo "⚠️  PostgreSQL is not running. Make sure to start your database."
    fi
fi

# Check if Redis is running (optional check)
if command -v redis-cli &> /dev/null; then
    if redis-cli ping &> /dev/null; then
        echo "✅ Redis is running"
    else
        echo "⚠️  Redis is not running. Make sure to start your cache server."
    fi
fi

echo ""
echo "🌍 Starting YeDeli Backend Server..."
echo "📱 API will be available at: http://localhost:3001"
echo "🔗 Health check: http://localhost:3001/health"
echo "📚 API docs: Check README.md for endpoint documentation"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
npm run dev
