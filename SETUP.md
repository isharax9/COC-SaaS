# COC-SaaS Setup Guide - Phase 1.5

> Complete setup instructions for getting COC-SaaS running locally

## Prerequisites

- **Node.js** 18+ ([Download](https://nodejs.org/))
- **Docker & Docker Compose** ([Download](https://www.docker.com/get-started))
- **Git** ([Download](https://git-scm.com/))
- **Clash of Clans API Token** ([Get here](https://developer.clashofclans.com/))

---

## Step 1: Clone with Submodules

```bash
# Clone the main repository with all submodules
git clone --recurse-submodules https://github.com/isharax9/COC-SaaS.git
cd COC-SaaS

# If you already cloned without submodules:
git submodule init
git submodule update
```

Your directory structure should look like:
```
COC-SaaS/
├── frontend/          # Next.js submodule
├── backend/           # NestJS submodule
├── docker-compose.yml
└── .env.example
```

---

## Step 2: Environment Configuration

### Main Repository (.env)

```bash
# Copy the example environment file
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# Database
POSTGRES_DB=coc_saas
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_PORT=5432

# Redis
REDIS_PORT=6379

# Backend
BACKEND_PORT=3001
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
JWT_EXPIRES_IN=7d

# Frontend
FRONTEND_PORT=3000
FRONTEND_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_WS_URL=ws://localhost:3001

# Clash of Clans API
COC_API_TOKEN=your-coc-api-token-here
```

### Get Your CoC API Token

1. Go to [https://developer.clashofclans.com/](https://developer.clashofclans.com/)
2. Login with your Supercell ID
3. Create a new API key:
   - **Name**: COC-SaaS Development
   - **Description**: Local development
   - **IP Address**: Your public IP (find at [https://whatismyipaddress.com/](https://whatismyipaddress.com/))
4. Copy the token to your `.env` file

---

## Step 3: Start Services with Docker

### Option A: Start Everything (Recommended)

```bash
# Start all services (Database, Redis, Backend, Frontend)
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Option B: Start Only Infrastructure

If you want to run backend/frontend manually:

```bash
# Start only PostgreSQL and Redis
docker-compose up -d postgres redis
```

---

## Step 4: Backend Setup

### If using Docker (Skip if using Option A above)

Backend is already running! Skip to Step 5.

### If running manually:

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env
# Edit backend/.env with same values as main .env

# Wait for database to be ready
# Then run migrations (database schema creation)
npm run migration:run

# Start development server
npm run start:dev
```

Backend should now be running at [http://localhost:3001](http://localhost:3001)

### Verify Backend

```bash
# Check API health
curl http://localhost:3001

# View Swagger documentation
open http://localhost:3001/api
```

---

## Step 5: Frontend Setup

### If using Docker (Skip if using Option A)

Frontend is already running! Skip to Step 6.

### If running manually:

```bash
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env
# Ensure NEXT_PUBLIC_API_URL matches your backend URL

# Start development server
npm run dev
```

Frontend should now be running at [http://localhost:3000](http://localhost:3000)

---

## Step 6: Database Initialization

The database schema is automatically created when the backend starts.

### Default Super Admin Account

```
Email: admin@cocsaas.com
Username: mac_knight141
Password: Admin123!
```

**⚠️ IMPORTANT**: Change this password immediately after first login!

### Manual Database Inspection

```bash
# Connect to PostgreSQL
docker exec -it coc-saas-postgres psql -U postgres -d coc_saas

# List tables
\dt

# View users
SELECT * FROM users;

# Exit
\q
```

---

## Step 7: Test the Application

### 1. Register a New User

1. Open [http://localhost:3000](http://localhost:3000)
2. Click "Get Started" or navigate to Register
3. Fill in the form:
   - Email: `yourname@example.com`
   - Username: `your_username`
   - Display Name: `Your Name`
   - Password: `YourPassword123!` (must have uppercase, lowercase, number)
4. Click "Create Account"

### 2. Link a Clash of Clans Player

1. After login, go to Dashboard
2. Navigate to "Settings" or "Profile"
3. Click "Link Player"
4. Get your API token from Clash of Clans:
   - Open Clash of Clans mobile app
   - Go to Settings → More Settings → API Token
   - Copy the token
5. Enter:
   - Player Tag: `#2PP` (or your actual tag)
   - API Token: (paste from game)
6. Click "Link Player"

### 3. Register Your Clan

1. Navigate to "Clans" or "Tenants"
2. Click "Register New Clan"
3. Enter:
   - Clan Tag: `#2YUL2PRYG` (or your clan's tag)
   - Description: Optional
4. Click "Register"

You're now the **Leader** of this clan in the app!

---

## Step 8: Verify Everything Works

### Backend API Tests

```bash
# Test user registration
curl -X POST http://localhost:3001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "Test123!",
    "displayName": "Test User"
  }'

# Test login
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

### Frontend Tests

- ✅ Landing page loads
- ✅ Register page works
- ✅ Login redirects to dashboard
- ✅ Dashboard shows user info
- ✅ Logout works and redirects to login

---

## Troubleshooting

### Database Connection Failed

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# View PostgreSQL logs
docker logs coc-saas-postgres

# Restart PostgreSQL
docker-compose restart postgres
```

### Backend Won't Start

```bash
# Check backend logs
docker logs coc-saas-backend

# Common issues:
# 1. Database not ready - wait 10 seconds and retry
# 2. Port 3001 in use - change BACKEND_PORT in .env
# 3. Missing COC_API_TOKEN - add to .env
```

### Frontend Can't Connect to Backend

1. Check `NEXT_PUBLIC_API_URL` in frontend `.env`
2. Verify backend is running: `curl http://localhost:3001`
3. Check browser console for CORS errors
4. Ensure backend `.env` has correct `FRONTEND_URL`

### CoC API Errors

```bash
# Common issues:
# 1. Invalid API token - regenerate at developer.clashofclans.com
# 2. IP address mismatch - update API key with current IP
# 3. Rate limiting - reduce polling frequency
```

### Player/Clan Verification Failed

1. Ensure API token is from the correct player/clan leader
2. Check that player tag format is correct: `#ABC123`
3. Verify you have internet connection to reach Supercell API
4. Check backend logs for specific error messages

---

## Docker Commands Reference

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart backend

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Rebuild after code changes
docker-compose up -d --build

# Remove all data (⚠️ WARNING: Deletes database)
docker-compose down -v

# Access database shell
docker exec -it coc-saas-postgres psql -U postgres -d coc_saas

# Access Redis CLI
docker exec -it coc-saas-redis redis-cli
```

---

## Development Workflow

### Making Changes to Backend

```bash
cd backend

# Code changes auto-reload with nodemon
# Add new migration:
npm run migration:generate -- src/database/migrations/AddWarTable
npm run migration:run

# Run tests
npm run test
```

### Making Changes to Frontend

```bash
cd frontend

# Changes auto-reload with Next.js Fast Refresh
# Add new component:
mkdir -p src/components/war
touch src/components/war/war-room.tsx

# Type check
npm run type-check
```

### Working with Git Submodules

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Make changes in a submodule
cd backend
git checkout -b feature/my-feature
# ... make changes ...
git commit -m "feat: add my feature"
git push origin feature/my-feature

# Update main repo to point to new commit
cd ..
git add backend
git commit -m "chore: update backend submodule"
git push
```

---

## Next Steps

✅ **Phase 1 Complete!** You now have:
- User registration and authentication
- Player verification with CoC API
- Clan registration
- Multi-tenant architecture
- RBAC system

### Phase 2: War Tracking (Next)

Ready to implement:
- War polling engine with BullMQ
- War Room dashboard
- Base calling system
- Attack tracking

Run: `npm run setup:phase2` (coming soon)

---

## Support

- **Documentation**: See README.md in each submodule
- **API Docs**: http://localhost:3001/api
- **Issues**: [GitHub Issues](https://github.com/isharax9/COC-SaaS/issues)

---

**Built with ❤️ by mac_knight141**