# Prisma Setup Guide - COC-SaaS

> Complete guide for setting up Prisma ORM with PostgreSQL

## What is Prisma?

Prisma is a modern ORM (Object-Relational Mapping) tool that provides:
- Type-safe database queries
- Auto-generated TypeScript types
- Intuitive data modeling
- Visual database browser (Prisma Studio)
- Automatic migrations

## Phase 1.5 Setup Steps

### Step 1: Clone and Initialize

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/isharax9/COC-SaaS.git
cd COC-SaaS

# Pull latest backend code
cd backend
git pull origin main
cd ..
```

### Step 2: Install Dependencies

```bash
# Backend dependencies
cd backend
npm install
cd ..

# Frontend dependencies
cd frontend
npm install
cd ..
```

### Step 3: Configure Environment

```bash
# Copy environment files
cp .env.example .env
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

**Edit `backend/.env`:**

```bash
# Database URL - MOST IMPORTANT
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/coc_saas?schema=public"

# JWT Secret (generate a random 32+ character string)
JWT_SECRET="your-random-jwt-secret-min-32-characters-here"
JWT_EXPIRES_IN=7d

# CoC API Token (get from https://developer.clashofclans.com/)
COC_API_TOKEN="your-coc-api-token-here"

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Frontend URL
FRONTEND_URL=http://localhost:3000
```

### Step 4: Start Database

```bash
# Start PostgreSQL and Redis with Docker
docker-compose up -d postgres redis

# Wait 10 seconds for database to initialize
sleep 10

# Verify database is running
docker ps | grep postgres
```

### Step 5: Initialize Prisma

```bash
cd backend

# Generate Prisma Client (creates TypeScript types)
npm run prisma:generate

# Create database tables (run migrations)
npm run prisma:migrate
# When prompted, name it: "init"

# Seed database with super admin account
npm run prisma:seed
```

**Expected Output:**
```
🌱 Seeding database...
✅ Created Super Admin: admin@cocsaas.com
✅ Created Demo User: demo@cocsaas.com
🎉 Seeding completed!
```

### Step 6: Start Backend

```bash
# Still in backend directory
npm run start:dev
```

**Expected Output:**
```
✅ Database connected successfully
🚀 COC-SaaS Backend API is running on: http://localhost:3001
📚 API Documentation available at: http://localhost:3001/api
```

### Step 7: Start Frontend

```bash
# Open new terminal
cd frontend
npm run dev
```

**Expected Output:**
```
  ▲ Next.js 14.0.0
  - Local:        http://localhost:3000
  - Ready in 2.3s
```

### Step 8: Test the System

1. **Open Prisma Studio** (Database GUI):
   ```bash
   cd backend
   npm run prisma:studio
   ```
   Opens at: http://localhost:5555

2. **Open Swagger API Docs**:
   http://localhost:3001/api

3. **Open Frontend**:
   http://localhost:3000

4. **Test Login** with seeded account:
   - Email: `admin@cocsaas.com`
   - Password: `Admin123!`

---

## Common Issues and Solutions

### Issue 1: "Can't reach database server"

**Cause**: PostgreSQL not running

**Solution**:
```bash
# Check if container is running
docker ps | grep postgres

# If not running, start it
docker-compose up -d postgres

# Check logs
docker logs coc-saas-postgres
```

### Issue 2: "Prisma Client not generated"

**Cause**: Prisma Client wasn't generated after schema changes

**Solution**:
```bash
cd backend
npm run prisma:generate
```

### Issue 3: "Migration failed"

**Cause**: Database state doesn't match schema

**Solution**:
```bash
cd backend

# Reset database (WARNING: Deletes all data)
npx prisma migrate reset

# Re-run migrations
npm run prisma:migrate

# Re-seed
npm run prisma:seed
```

### Issue 4: "Port 5432 already in use"

**Cause**: Another PostgreSQL instance is running

**Solution**:
```bash
# Option 1: Stop other PostgreSQL
sudo systemctl stop postgresql

# Option 2: Change port in docker-compose.yml
# Change "5432:5432" to "5433:5432"
# Then update DATABASE_URL to use port 5433
```

### Issue 5: "JWT_SECRET not defined"

**Cause**: Environment variable not loaded

**Solution**:
```bash
# Ensure .env file exists in backend/
cd backend
cat .env | grep JWT_SECRET

# If empty, add:
echo "JWT_SECRET=your-secret-key-min-32-chars" >> .env

# Restart backend
npm run start:dev
```

---

## Prisma Workflow Guide

### Making Schema Changes

1. **Edit Schema**:
   ```bash
   cd backend
   nano prisma/schema.prisma
   ```

2. **Example: Add a new field to User**:
   ```prisma
   model User {
     // ... existing fields
     bio String? // Add this line
   }
   ```

3. **Create Migration**:
   ```bash
   npm run prisma:migrate
   # Name: "add_bio_to_user"
   ```

4. **Prisma Client auto-regenerates**

5. **Use in code**:
   ```typescript
   const user = await this.prisma.user.update({
     where: { id: userId },
     data: { bio: 'Hello!' },
   });
   ```

### Viewing Data (Prisma Studio)

```bash
cd backend
npm run prisma:studio
```

Features:
- Browse all tables
- Edit data visually
- Run queries
- View relationships

### Querying Data

**Basic Query**:
```typescript
const user = await prisma.user.findUnique({
  where: { email: 'test@example.com' },
});
```

**With Relations**:
```typescript
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    players: true,
    memberships: {
      include: { tenant: true },
    },
  },
});
```

**Create**:
```typescript
const newUser = await prisma.user.create({
  data: {
    email: 'new@example.com',
    username: 'newuser',
    password: hashedPassword,
  },
});
```

**Update**:
```typescript
await prisma.user.update({
  where: { id: userId },
  data: { displayName: 'New Name' },
});
```

**Delete**:
```typescript
await prisma.user.delete({
  where: { id: userId },
});
```

---

## Production Deployment

### 1. Database Setup

```bash
# Set production DATABASE_URL in .env
DATABASE_URL="postgresql://user:pass@prod-host:5432/coc_saas"

# Deploy migrations (no interactive prompts)
npm run prisma:migrate:deploy

# Generate Prisma Client
npm run prisma:generate
```

### 2. Don't Run Seed in Production

```bash
# NEVER run this in production:
# npm run prisma:seed

# Instead, create admin manually via API:
curl -X POST http://your-api.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourcompany.com",
    "username": "admin",
    "password": "SecurePassword123!"
  }'

# Then update isPlatformAdmin in database
```

### 3. Enable Connection Pooling

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // Add connection pool
  relationMode = "prisma"
}
```

---

## Useful Commands Reference

```bash
# Generate Prisma Client
npm run prisma:generate

# Create migration
npm run prisma:migrate

# Deploy migrations (production)
npm run prisma:migrate:deploy

# Open Prisma Studio
npm run prisma:studio

# Seed database
npm run prisma:seed

# Reset database (DANGER)
npx prisma migrate reset

# Validate schema
npx prisma validate

# Format schema file
npx prisma format

# Check migration status
npx prisma migrate status
```

---

## Next Steps

✅ **Phase 1.5 Complete!** You now have:
- Prisma ORM configured
- Database schema deployed
- Type-safe queries
- Seeded data
- Working authentication

### Ready for Phase 2: War Tracking

The Prisma schema already includes `War`, `WarParticipant`, and `Attack` models.

Next, we'll implement:
1. BullMQ job queues
2. CoC API polling engine
3. War Room dashboard
4. Real-time attack notifications

---

**Questions?** Check the [Backend README](./backend/README.md) or open an issue.

**Built with ❤️ by mac_knight141**