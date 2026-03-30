# Gym Scores

A web application for tracking gymnastics competition scores. Scrapes data from MyMeetScores and MeetScoresOnline, then presents it in a clean, modern interface with progress charts.

## Features

- **Score Aggregation**: Scrapes gymnast scores from multiple sources
- **Progress Tracking**: Visualize score trends over time with charts
- **Personal Bests**: Automatic tracking of best scores by level and event
- **Meet History**: Complete competition history with rankings

## Tech Stack

- **Backend**: Ruby on Rails 8 (API mode)
- **Frontend**: React + TypeScript + Vite
- **Styling**: Tailwind CSS
- **Charts**: Recharts
- **Database**: SQLite

## Getting Started

### Option 1: Docker (Recommended)

The easiest way to run the app is with Docker Compose.

**Production build:**

```bash
# Set your Rails master key (check backend/config/master.key)
export RAILS_MASTER_KEY=<your-master-key>

# Build and run
docker compose up --build
```

The app will be available at http://localhost

**Development mode:**

```bash
docker compose -f docker-compose.dev.yml up --build
```

- Frontend: http://localhost:5173 (with hot reload)
- Backend: http://localhost:3000 (with hot reload)

### Option 2: Local Development

#### Prerequisites

- Ruby 3.3+
- Node.js 20+
- npm

#### Backend Setup

```bash
cd backend
bundle install
bin/rails db:migrate
bin/rails server
```

#### Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

The frontend runs on http://localhost:5173 and proxies API requests to the Rails backend on http://localhost:3000.

## Usage

1. Open http://localhost:5173
2. Paste a MyMeetScores gymnast URL (e.g., `https://mymeetscores.com/gymnast.pl?gymnastid=12345`)
3. Click "Add" to scrape and store the gymnast's scores
4. View score history, progress charts, and personal bests

## API Endpoints

- `GET /api/v1/gymnasts` - List all gymnasts
- `GET /api/v1/gymnasts/:id` - Get gymnast details with scores
- `POST /api/v1/scrape` - Add a new gymnast by URL
- `POST /api/v1/gymnasts/:id/refresh` - Refresh scores from source
