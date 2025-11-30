# COC-SaaS - Clash of Clans Clan Management Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Frontend](https://img.shields.io/badge/Frontend-Next.js-black)](https://github.com/isharax9/COC-SaaS-Frontend)
[![Backend](https://img.shields.io/badge/Backend-NestJS-red)](https://github.com/isharax9/COC-SaaS-Backend)

> A comprehensive, scalable SaaS platform for Clash of Clans clans to track wars, raids, player statistics, and communication - built with Next.js, NestJS, and PostgreSQL.

## 🎯 Project Vision

COC-SaaS transforms ephemeral Clash of Clans game data into persistent, actionable insights. Track every war attack, raid weekend, player upgrade, and clan activity with real-time notifications and advanced analytics.

## ✨ Key Features

### 🗡️ War Management
- **Live War Room Dashboard** - Real-time attack tracking with visual base grid
- **Base Calling System** - Reserve bases to prevent double attacks
- **Attack Analytics** - Track stars, destruction %, fresh hits, and performance trends
- **War Weight Calculator** - Analyze matchmaking fairness

### 🏰 Raid Weekend Tracking
- **Participation Monitoring** - Track all 6 attacks per player
- **Capital Gold Analytics** - Monitor loot and district destruction
- **Defaulter Highlighting** - Identify inactive players instantly

### 💬 Advanced Communication
- **Multi-Channel Chat** - Discord-grade messaging with threads
- **Rich Media Support** - Images, videos, markdown formatting
- **Reaction System** - Emoji reactions on messages
- **System Notifications** - Automated bot announcements for game events

### 📊 Player Analytics
- **Upgrade Tracker** - Monitor progression for each Town Hall level
- **Donation Tracking** - Troop donation ratios and statistics
- **Activity Scores** - Comprehensive player engagement metrics
- **Historical Performance** - Long-term war and raid statistics

### 🔐 Role-Based Access Control
- **Multi-Tier Permissions**: Member → Elder → Co-Leader → Leader → Super Admin
- **Tenant Isolation** - Secure multi-clan architecture
- **Player Verification** - Supercell API token-based ownership proof

## 🏗️ Architecture

This repository uses a **Git Submodule** architecture for clean separation:

```
COC-SaaS/ (Main Repository)
├── frontend/          → COC-SaaS-Frontend submodule
├── backend/           → COC-SaaS-Backend submodule
├── docker-compose.yml
└── README.md
```

### Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|----------|
| **Frontend** | Next.js 14+ (React, TypeScript) | SSR, SEO optimization, responsive UI |
| **Backend** | NestJS (Node.js, TypeScript) | Modular API, WebSocket gateway, job queues |
| **Database** | PostgreSQL 15+ | Multi-tenant data with JSONB flexibility |
| **Cache/Queue** | Redis 7+ | Rate limiting, BullMQ jobs, Socket.io pub/sub |
| **Real-time** | Socket.io | Live war updates, chat messaging |
| **API Integration** | Clash of Clans API | Game data ingestion |

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker & Docker Compose
- Git
- Clash of Clans API Token ([Get one here](https://developer.clashofclans.com/))

### Installation

1. **Clone the repository with submodules**
```bash
git clone --recurse-submodules https://github.com/isharax9/COC-SaaS.git
cd COC-SaaS
```

2. **If you already cloned without submodules**
```bash
git submodule init
git submodule update
```

3. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Start with Docker Compose**
```bash
docker-compose up -d
```

5. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- API Documentation: http://localhost:3001/api

## 📁 Repository Structure

```
COC-SaaS/
├── frontend/                  # Next.js frontend submodule
│   ├── src/
│   │   ├── app/              # Next.js 14 App Router
│   │   ├── components/       # React components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── lib/             # Utilities and helpers
│   │   └── types/           # TypeScript definitions
│   └── package.json
│
├── backend/                   # NestJS backend submodule
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/        # Authentication & JWT
│   │   │   ├── tenant/      # Clan management
│   │   │   ├── user/        # User profiles
│   │   │   ├── war/         # War tracking
│   │   │   ├── chat/        # WebSocket messaging
│   │   │   ├── ingestion/   # API polling engine
│   │   │   └── analytics/   # Statistics aggregation
│   │   ├── common/          # Shared utilities
│   │   └── main.ts
│   └── package.json
│
├── docker-compose.yml         # Multi-container orchestration
├── .env.example              # Environment template
├── LICENSE                   # MIT License
└── README.md
```

## 🔧 Development

### Working with Submodules

**Pull latest changes from all submodules:**
```bash
git submodule update --remote --merge
```

**Make changes in a submodule:**
```bash
cd frontend
git checkout -b feature/my-feature
# Make changes
git commit -m "feat: add my feature"
git push origin feature/my-feature
```

**Update main repo to point to new submodule commit:**
```bash
cd ..
git add frontend
git commit -m "chore: update frontend submodule"
git push
```

### Running Services Individually

**Frontend Development:**
```bash
cd frontend
npm install
npm run dev
```

**Backend Development:**
```bash
cd backend
npm install
npm run start:dev
```

## 📋 Phase 1 Implementation Checklist

- [x] Repository structure with submodules
- [x] MIT License setup
- [x] Docker Compose configuration
- [ ] NestJS backend initialization
  - [ ] Auth module with JWT
  - [ ] Tenant module
  - [ ] User module with RBAC
  - [ ] PostgreSQL schema migration
- [ ] Next.js frontend initialization
  - [ ] Authentication pages
  - [ ] Layout components
  - [ ] API client setup
- [ ] Player verification with Supercell API
- [ ] Multi-tenancy database schema

## 🎯 Roadmap

### Phase 1: Foundation ✅ (Current)
- Core authentication system
- Multi-tenant architecture
- Player verification

### Phase 2: War Tracking (Next)
- API polling engine with BullMQ
- War Room dashboard
- Base calling system

### Phase 3: Real-Time Communication
- Socket.io chat implementation
- Multi-channel messaging
- Bot notifications

### Phase 4: Advanced Features
- Raid Weekend tracking
- Analytics dashboard
- Upgrade tracker

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Copyright (c) 2025 Ishara "mac_knight141" Lakshitha**

## 🔗 Links

- [Frontend Repository](https://github.com/isharax9/COC-SaaS-Frontend)
- [Backend Repository](https://github.com/isharax9/COC-SaaS-Backend)
- [Clash of Clans API Documentation](https://developer.clashofclans.com/)

## 💡 Inspiration

Built to solve the transient data problem in Clash of Clans and provide competitive clans with enterprise-grade tools for strategic advantage.

---

**Built with ❤️ by mac_knight141**