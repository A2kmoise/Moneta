#!/bin/bash

# FinApp Backend Setup Script
# This script sets up the backend environment and database

set -e

echo "🚀 FinApp Backend Setup"
echo "======================="

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed"
    echo "Installing PostgreSQL..."
    brew install postgresql@15
    brew services start postgresql@15
else
    echo "✅ PostgreSQL is installed"
fi

# Check if database exists
if psql -lqt | cut -d \| -f 1 | grep -qw budget_db; then
    echo "✅ Database 'budget_db' already exists"
else
    echo "📦 Creating database 'budget_db'..."
    createdb budget_db
    echo "✅ Database created"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created (please update with your settings)"
else
    echo "✅ .env file already exists"
fi

# Build the project
echo "🔨 Building project..."
swift build

# Run migrations
echo "🗄️  Running database migrations..."
swift run Run migrate --yes

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the server, run:"
echo "  swift run Run serve"
echo ""
echo "Server will be available at: http://localhost:8080"
echo ""
echo "📚 Check README.md for API documentation"
echo "📱 Check INTEGRATION_GUIDE.md for iOS app integration"
