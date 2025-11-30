#!/bin/bash

# Health Check Script for COC-SaaS
# Run with: bash scripts/check-health.sh

echo "🏥 COC-SaaS Health Check"
echo "========================"
echo ""

# Check Docker services
echo "🐳 Docker Services:"
docker-compose ps
echo ""

# Check PostgreSQL
echo "🗄️  PostgreSQL:"
if docker exec coc-saas-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL is healthy"
else
    echo "❌ PostgreSQL is not responding"
fi
echo ""

# Check Redis
echo "📦 Redis:"
if docker exec coc-saas-redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis is healthy"
else
    echo "❌ Redis is not responding"
fi
echo ""

# Check Backend API
echo "🔧 Backend API:"
if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "✅ Backend API is responding"
    echo "   Swagger: http://localhost:3001/api"
else
    echo "❌ Backend API is not responding"
fi
echo ""

# Check Frontend
echo "🎨 Frontend:"
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend is responding"
    echo "   URL: http://localhost:3000"
else
    echo "❌ Frontend is not responding"
fi
echo ""

echo "Health check complete!"