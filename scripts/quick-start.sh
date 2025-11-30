#!/bin/bash

# COC-SaaS Quick Start with Prisma
# Run: bash scripts/quick-start.sh

set -e

echo ""
echo "🚀 COC-SaaS Phase 1.5 Quick Start"
echo "===================================="
echo "Setting up with Prisma ORM..."
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the COC-SaaS root directory"
    exit 1
fi

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install Node.js 18+ first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Install Docker Compose first."
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
if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo "✅ Created backend/.env"
    echo "⚠️  IMPORTANT: Edit backend/.env and set:"
    echo "   - DATABASE_URL"
    echo "   - JWT_SECRET"
    echo "   - COC_API_TOKEN"
    echo ""
else
    echo "✅ backend/.env already exists"
fi

if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.example frontend/.env
    echo "✅ Created frontend/.env"
else
    echo "✅ frontend/.env already exists"
fi
echo ""

# Start database
echo "🐳 Starting PostgreSQL and Redis..."
docker-compose up -d postgres redis

echo "⏳ Waiting for database to be ready..."
sleep 10

if docker exec coc-saas-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
else
    echo "❌ PostgreSQL failed to start. Check docker logs."
    exit 1
fi
echo ""

# Install backend dependencies
echo "📚 Installing backend dependencies..."
cd backend
npm install --silent
echo "✅ Backend dependencies installed"
echo ""

# Setup Prisma
echo "🔧 Setting up Prisma..."
echo "Generating Prisma Client..."
npm run prisma:generate
echo "✅ Prisma Client generated"

echo "Running database migrations..."
npm run prisma:migrate
echo "✅ Migrations applied"

echo "Seeding database..."
npm run prisma:seed
echo "✅ Database seeded"
echo ""

cd ..

# Install frontend dependencies
echo "📚 Installing frontend dependencies..."
cd frontend
npm install --silent
echo "✅ Frontend dependencies installed"
echo ""

cd ..

echo "✅ Setup Complete!"
echo ""
echo "===================================="
echo "🎉 Ready to Start Development!"
echo "===================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Start Backend:"
echo "   cd backend && npm run start:dev"
echo ""
echo "2. Start Frontend (in new terminal):"
echo "   cd frontend && npm run dev"
echo ""
echo "3. Open Prisma Studio (in new terminal):"
echo "   cd backend && npm run prisma:studio"
echo ""
echo "Access:"
echo "  - Frontend:      http://localhost:3000"
echo "  - Backend API:   http://localhost:3001"
echo "  - Swagger Docs:  http://localhost:3001/api"
echo "  - Prisma Studio: http://localhost:5555"
echo ""
echo "Default Login:"
echo "  Email:    admin@cocsaas.com"
echo "  Password: Admin123!"
echo ""
echo "For detailed setup, see: PRISMA_SETUP.md"
echo ""
echo "Happy coding! 🚀"
echo ""