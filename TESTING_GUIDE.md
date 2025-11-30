# Testing Guide - Phase 1 Features

## Manual Testing Checklist

### Frontend Testing

#### 1. Registration Flow
- [ ] Navigate to http://localhost:3000
- [ ] Click "Get Started" or "Sign up"
- [ ] Fill registration form:
  - Email: test@example.com
  - Username: testuser
  - Display Name: Test User
  - Password: password123
  - Confirm Password: password123
- [ ] Submit form
- [ ] Verify redirect to dashboard
- [ ] Verify welcome message shows username

#### 2. Login Flow
- [ ] Logout from dashboard
- [ ] Navigate to login page
- [ ] Enter credentials
- [ ] Click "Sign In"
- [ ] Verify redirect to dashboard
- [ ] Verify user data persists after page refresh

#### 3. Player Verification
- [ ] Open Clash of Clans mobile app
- [ ] Go to Settings → More Settings
- [ ] Copy API Token
- [ ] In dashboard, enter:
  - Player Tag: #YourTag
  - API Token: (paste token)
- [ ] Click "Link Player"
- [ ] Verify success message
- [ ] Verify player appears in "Your Players" section

#### 4. Protected Routes
- [ ] Logout
- [ ] Try accessing /dashboard directly
- [ ] Verify redirect to login
- [ ] Login again
- [ ] Verify dashboard access granted

### Backend API Testing

#### Using cURL

**1. Register New User**
```bash
curl -X POST http://localhost:3001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "username": "johndoe",
    "password": "securepass123",
    "displayName": "John Doe"
  }'
```

**Expected Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "john@example.com",
    "username": "johndoe",
    "displayName": "John Doe",
    "isPlatformAdmin": false
  }
}
```

**2. Login**
```bash
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepass123"
  }'
```

**3. Get Current User Profile**
```bash
TOKEN="your-jwt-token-here"

curl -X GET http://localhost:3001/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

**4. Link Clash of Clans Player**
```bash
TOKEN="your-jwt-token-here"

curl -X POST http://localhost:3001/users/me/players/link \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "playerTag": "#2PP",
    "apiToken": "your-coc-api-token"
  }'
```

**Expected Response:**
```json
{
  "id": "uuid-here",
  "playerTag": "#2PP",
  "playerName": "Goblin",
  "townHallLevel": 11,
  "expLevel": 123,
  "trophies": 3456,
  "clanTag": "#CLANID",
  "clanName": "Clan Name",
  "isVerified": true,
  "createdAt": "2025-11-30T..."
}
```

**5. Get Linked Players**
```bash
TOKEN="your-jwt-token-here"

curl -X GET http://localhost:3001/users/me/players \
  -H "Authorization: Bearer $TOKEN"
```

### Using Postman/Insomnia

#### Import Collection

Create a new collection with these requests:

**Environment Variables:**
- `base_url`: http://localhost:3001
- `token`: (will be set after login)

**Requests:**

1. **POST** Register
   - URL: `{{base_url}}/auth/register`
   - Body (JSON):
   ```json
   {
     "email": "test@example.com",
     "username": "testuser",
     "password": "password123"
   }
   ```
   - Test Script: Save `access_token` to environment

2. **POST** Login
   - URL: `{{base_url}}/auth/login`
   - Body (JSON):
   ```json
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

3. **GET** Get Profile
   - URL: `{{base_url}}/auth/me`
   - Headers: `Authorization: Bearer {{token}}`

4. **POST** Link Player
   - URL: `{{base_url}}/users/me/players/link`
   - Headers: `Authorization: Bearer {{token}}`
   - Body (JSON):
   ```json
   {
     "playerTag": "#YourTag",
     "apiToken": "YourToken"
   }
   ```

### Database Testing

#### Connect to PostgreSQL
```bash
docker-compose exec postgres psql -U postgres -d coc_saas
```

#### Verify User Creation
```sql
SELECT id, email, username, "isPlatformAdmin", "createdAt" 
FROM users;
```

#### Verify Player Linking
```sql
SELECT 
  p."playerTag", 
  p."playerName", 
  p."townHallLevel",
  u.username as linked_user
FROM players p
JOIN users u ON p."userId" = u.id;
```

#### Check Memberships
```sql
SELECT 
  m.role,
  u.username,
  t."clanName"
FROM memberships m
JOIN users u ON m."userId" = u.id
JOIN tenants t ON m."tenantId" = t.id;
```

## Error Testing

### 1. Duplicate Registration
- Try registering with same email
- **Expected**: 409 Conflict - "Email already in use"

### 2. Invalid Login
- Try login with wrong password
- **Expected**: 401 Unauthorized - "Invalid credentials"

### 3. Invalid JWT
- Send request with invalid/expired token
- **Expected**: 401 Unauthorized - "Invalid token"

### 4. Invalid Player Tag
- Try linking with non-existent player tag
- **Expected**: 400 Bad Request - "Player not found"

### 5. Invalid API Token
- Try linking with wrong API token
- **Expected**: 400 Bad Request - "Player verification failed"

### 6. Duplicate Player Link
- Try linking same player twice
- **Expected**: 409 Conflict - "Player already linked"

## Performance Testing

### Load Test with k6

Create `load-test.js`:
```javascript
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  // Register
  let registerRes = http.post(
    'http://localhost:3001/auth/register',
    JSON.stringify({
      email: `test${__VU}@example.com`,
      username: `user${__VU}`,
      password: 'password123'
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  
  check(registerRes, {
    'registration successful': (r) => r.status === 201 || r.status === 409,
  });
}
```

Run:
```bash
k6 run load-test.js
```

## Security Testing

### 1. SQL Injection Prevention
- Try injecting SQL in username: `admin' OR '1'='1`
- **Expected**: Validation error or safe handling

### 2. XSS Prevention
- Try registering with: `<script>alert('xss')</script>`
- **Expected**: Escaped or rejected

### 3. Password Hashing
```sql
SELECT password FROM users LIMIT 1;
```
- **Expected**: Hashed string (bcrypt format starting with $2b$)

### 4. JWT Secret
- Verify JWT_SECRET is not hardcoded
- Check it's loaded from environment

## Integration Testing

### Full User Journey
1. Register new account
2. Verify redirect to dashboard
3. Check user profile displays correctly
4. Link Clash of Clans player
5. Verify player appears in list
6. Logout
7. Login again
8. Verify session persisted
9. Verify player still linked

## Automated Testing (Future)

### Backend Unit Tests (Jest)
```bash
cd backend
npm run test
npm run test:e2e
```

### Frontend Tests (React Testing Library)
```bash
cd frontend
npm run test
```

## Success Criteria

✅ Phase 1 is considered complete when:
- [ ] All manual tests pass
- [ ] User can register and login
- [ ] JWT authentication works correctly
- [ ] Player verification succeeds with valid credentials
- [ ] Protected routes are properly guarded
- [ ] Database correctly stores all data
- [ ] No console errors in browser
- [ ] No errors in backend logs
- [ ] Docker containers run without issues

## Troubleshooting

### Frontend can't connect to backend
```bash
# Check backend is running
docker-compose ps

# Check backend logs
docker-compose logs backend

# Verify NEXT_PUBLIC_API_URL in frontend .env
```

### Database connection errors
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check DATABASE_URL in backend .env
# Run migrations again
docker-compose exec backend npm run prisma:migrate:deploy
```

### Player verification fails
- Verify API token is current (tokens expire after a few minutes)
- Ensure player tag format is correct (#TAG)
- Check Supercell API is accessible
- Verify COC_API_TOKEN in backend .env

## Reporting Issues

When reporting issues, include:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Error messages (frontend console + backend logs)
5. Environment (OS, Docker version, Node version)
