#!/bin/bash

# COC-SaaS Quick Setup Script
# Run with: bash scripts/setup.sh

set -e

echo "🚀 COC-SaaS Quick Setup"
echo "========================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ All prerequisites installed"
echo ""

# Initialize submodules
echo "📦 Initializing submodules..."
if [ ! -d "backend/.git" ] || [ ! -d "frontend/.git" ]; then
    git submodule init
    git submodule update
    echo "✅ Submodules initialized"
else
    echo "✅ Submodules already initialized"
fi
echo ""

# Setup environment files
echo "⚙️  Setting up environment files..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Created .env from .env.example"
    echo "⚠️  Please edit .env and add your configuration"
else
    echo "✅ .env already exists"
fi

if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env 2>/dev/null || echo "Backend .env.example not found"
fi

if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.example frontend/.env 2>/dev/null || echo "Frontend .env.example not found"
fi
echo ""

# Install dependencies
echo "📚 Installing dependencies..."
echo "This may take a few minutes..."

if [ -d "backend" ]; then
    echo "Installing backend dependencies..."
    cd backend
    npm install --quiet
    cd ..
    echo "✅ Backend dependencies installed"
fi

if [ -d "frontend" ]; then
    echo "Installing frontend dependencies..."
    cd frontend
    npm install --quiet
    cd ..
    echo "✅ Frontend dependencies installed"
fi
echo ""

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d postgres redis

echo "⏳ Waiting for database to be ready..."
sleep 10

echo "✅ Docker services started"
echo ""

# Check if COC_API_TOKEN is set
if ! grep -q "COC_API_TOKEN=eyJ" .env; then
    echo "⚠️  WARNING: COC_API_TOKEN not configured in .env"
    echo "Please get your API token from https://developer.clashofclans.com/"
    echo "And add it to the .env file"
    echo ""
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env and add your COC_API_TOKEN"
echo "2. Run 'docker-compose up -d' to start all services"
echo "3. Open http://localhost:3000 in your browser"
echo ""
echo "For detailed instructions, see SETUP.md"
echo ""
echo "Happy coding! 🎉"