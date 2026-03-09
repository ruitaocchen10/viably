# CLAUDE.md

# viably

A gamified iOS habit tracker with social accountability features — think Strava, but for life habits.

## What we're building

Users build daily habits, complete them to build and maintain streaks, then share their day as a "Viable Score" to a friend feed for social accountability.

## Core features (MVP)

### 1. Habit tracking + gamification

- Users create habits and check them off daily
- Each habit has a **streak counter** (🔥 N days) — the primary emotional hook
- Completing habits earns **XP** toward a daily bar (total day score is equal to the addition of all the existing streaks)

### 2. Minimum Viable Day (MVD)

- Users tag certain habits as MVD — the non-negotiables
- MVD habits are visually distinct (purple tag)
- Completing all MVD habits = a viable day regardless of total score

### 3. Daily Viable Score + social sharing

- Each day generates a score based on habit completion
- Users can post their score to a **friend feed**
- Posts show score, which habits were done, and a caption
- Friends can react with 🔥 Hype

## Tech stack

- **SwiftUI** — iOS 17+ UI framework
- **Supabase** — backend-as-a-service providing:
  - **Postgres** database (habits, streaks, scores, posts)
  - **Auth** — OAuth via Google (Sign in with Apple + others planned)
  - **Realtime** subscriptions (friend feed live updates)
  - Swift SDK: `supabase-swift` package

## What good looks like

A first-time user should be able to: create 3 habits, mark one as MVD, complete them, see their daily score bar fill, and share their day — all within 5 minutes of opening the app.
