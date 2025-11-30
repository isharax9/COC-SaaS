# Quick Start Guide - COC SaaS Platform

## 🚀 Get Up and Running in 5 Minutes

### Prerequisites

Make sure you have these installed:
- **Docker** (v20.10+) - [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose** (v2.0+) - Usually comes with Docker Desktop
- **Git** - [Install Git](https://git-scm.com/downloads)

### Step 1: Clone the Repository

```bash
# Clone with submodules
git clone --recursive https://github.com/isharax9/COC-SaaS.git

# Navigate to project directory
cd COC-SaaS

# If you forgot --recursive, initialize submodules now:
git submodule update --init --recursive
```

### Step 2: Configure Environment Variables

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your preferred editor
nano .env  # or vim, code, etc.
```

**Required Variables:**
```env
# PostgreSQL Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password-here
POSTGRES_DB=coc_saas

# Backend
DATABASE_URL="postgresql://postgres:your-secure-password-here@postgres:5432/coc_saas?schema=public"
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# Clash of Clans API (get from https://developer.clashofclans.com)
COC_API_TOKEN=your-coc-api-token-here

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:3001
```

### Step 3: Start All Services

```bash
# Build and start all containers
docker-compose up -d

# Check if all services are running
docker-compose ps
```

You should see:
- ✅ postgres (port 5432)
- ✅ redis (port 6379)
- ✅ backend (port 3001)
- ✅ frontend (port 3000)

### Step 4: Initialize Database

```bash
# Run Prisma migrations to create tables
docker-compose exec backend npm run prisma:migrate:deploy

# Generate Prisma Client
docker-compose exec backend npm run prisma:generate

# (Optional) Seed initial data
docker-compose exec backend npm run seed
```

### Step 5: Access the Application

Open your browser and navigate to:

- **Frontend**: [http://localhost:3000](http://localhost:3000)
- **Backend API**: [http://localhost:3001](http://localhost:3001)
- **API Docs**: [http://localhost:3001/api](http://localhost:3001/api) (if Swagger enabled)

### Step 6: Create Your First Account

1. Click **"Get Started"** on the homepage
2. Fill out the registration form:
   - Email: `your@email.com`
   - Username: `yourusername`
   - Password: `secure-password-123`
   - Display Name: `Your Name`
3. Click **"Create Account"**
4. You'll be redirected to the dashboard!

### Step 7: Link Your Clash of Clans Account

1. Open **Clash of Clans** on your mobile device
2. Go to **Settings** → **More Settings**
3. Find and **copy your API Token** (it expires after a few minutes)
4. In the dashboard, find **"Link Your Account"** section
5. Enter:
   - **Player Tag**: `#YourPlayerTag` (with the # symbol)
   - **API Token**: (paste the token from step 3)
6. Click **"Link Player"**
7. Success! Your account is now linked 🎉

## 🛠️ Common Commands

### Managing Services

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Restart a service
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build
```

### Database Operations

```bash
# Access PostgreSQL CLI
docker-compose exec postgres psql -U postgres -d coc_saas

# Run migrations
docker-compose exec backend npm run prisma:migrate:deploy

# Reset database (WARNING: deletes all data)
docker-compose exec backend npm run prisma:migrate:reset

# Open Prisma Studio (GUI for database)
docker-compose exec backend npm run prisma:studio
# Then visit http://localhost:5555
```

### Development

```bash
# Install dependencies in backend
cd backend
npm install

# Install dependencies in frontend
cd frontend
npm install

# Run backend locally (without Docker)
cd backend
npm run start:dev

# Run frontend locally (without Docker)
cd frontend
npm run dev
```

## 🐞 Troubleshooting

### Issue: "Cannot connect to database"

```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Issue: "Frontend can't reach backend"

1. Verify backend is running:
   ```bash
   curl http://localhost:3001/health
   ```

2. Check `NEXT_PUBLIC_API_URL` in frontend `.env`:
   ```env
   NEXT_PUBLIC_API_URL=http://localhost:3001
   ```

3. Restart frontend:
   ```bash
   docker-compose restart frontend
   ```

### Issue: "Player verification fails"

**Causes:**
- API token expired (they expire after ~10 minutes)
- Invalid player tag format
- COC_API_TOKEN in backend .env is invalid

**Solution:**
1. Get a fresh API token from Clash of Clans
2. Ensure player tag starts with `#`
3. Verify your Clash of Clans API key at [developer.clashofclans.com](https://developer.clashofclans.com)

### Issue: "Port already in use"

```bash
# Check what's using the port
lsof -i :3000  # Frontend port
lsof -i :3001  # Backend port
lsof -i :5432  # PostgreSQL port

# Kill the process or change ports in docker-compose.yml
```

### Issue: Containers keep restarting

```bash
# Check logs for errors
docker-compose logs backend

# Common causes:
# 1. Missing environment variables
# 2. Database not ready yet
# 3. Dependency installation failed

# Try rebuilding
docker-compose down
docker-compose up -d --build
```

## 📚 Next Steps

Now that Phase 1 is complete, you can:

1. **Explore the API**
   - Use Postman/Insomnia to test endpoints
   - See [TESTING_GUIDE.md](TESTING_GUIDE.md) for examples

2. **Link Multiple Players**
   - Link all your Clash of Clans accounts
   - Manage multiple clans

3. **Prepare for Phase 2**
   - War tracking features coming next
   - Real-time attack visualization
   - Base calling system

4. **Customize**
   - Modify the UI theme in `frontend/tailwind.config.ts`
   - Add custom features
   - Extend the database schema

## 📝 Documentation

- [Phase 1 Completion Report](PHASE_1_COMPLETE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Setup Guide](SETUP.md)
- [Prisma Setup](PRISMA_SETUP.md)
- [Backend README](backend/README.md)
- [Frontend README](frontend/README.md)

## ❓ Need Help?

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section above
2. Review the logs: `docker-compose logs -f`
3. Ensure all environment variables are set correctly
4. Try rebuilding: `docker-compose up -d --build`

## 🎉 Success!

If you can:
- ✅ Register and login
- ✅ See the dashboard
- ✅ Link a Clash of Clans player

Congratulations! Phase 1 is working perfectly. Ready for Phase 2? 🚀

---

**Happy Coding!** 💻⚔️