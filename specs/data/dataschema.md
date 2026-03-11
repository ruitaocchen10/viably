# Viably Data Schema

## Overview

Supabase/Postgres schema for the Viably app. All tables use `uuid` primary keys and `timestamptz` for timestamps. Row-level security (RLS) should be enabled on all tables.

---

## Tables

### `profiles`

Extends Supabase `auth.users`. Created automatically on user signup via trigger.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | FK → auth.users |
| username | text UNIQUE NOT NULL | e.g. `@ruitao` |
| display_name | text | e.g. `"Ruitao Chen"` |
| avatar_url | text | |
| created_at | timestamptz DEFAULT now() | |

> **Derived stats** (Best Streak, High Score, Friends count) are computed queries — not stored columns.
> - **Best Streak**: `MAX(current_streak)` across user's habits (or historical max from `habit_completions`)
> - **High Score**: `MAX(score)` from `daily_scores`
> - **Friends**: `COUNT` of accepted rows in `friendships`

---

### `habits`

One row per habit per user.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| user_id | uuid NOT NULL FK → profiles | |
| name | text NOT NULL | e.g. `"Morning Run"` |
| description | text | optional detail text |
| icon | text | SF Symbol name or icon key |
| is_mvd | bool NOT NULL DEFAULT false | Minimum Viable Day toggle |
| is_active | bool NOT NULL DEFAULT true | false = shown in Inactive Habits section |
| current_streak | int NOT NULL DEFAULT 0 | cached streak; updated by DB trigger on completion/miss |
| created_at | timestamptz DEFAULT now() | |

---

### `habit_completions`

One row per habit per day it is checked off.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| habit_id | uuid NOT NULL FK → habits | |
| user_id | uuid NOT NULL FK → profiles | denormalized for RLS / query performance |
| completed_date | date NOT NULL | |
| created_at | timestamptz DEFAULT now() | |
| **UNIQUE** | (habit_id, completed_date) | prevents double-completion |

---

### `daily_scores`

Computed summary for each user's day. Upserted as habits are completed throughout the day.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| user_id | uuid NOT NULL FK → profiles | |
| score_date | date NOT NULL | |
| score | int NOT NULL DEFAULT 0 | sum of `current_streak` for completed habits that day |
| max_score | int NOT NULL DEFAULT 0 | sum of `current_streak` for all active habits |
| is_viable_day | bool NOT NULL DEFAULT false | true when all MVD habits completed |
| created_at | timestamptz DEFAULT now() | |
| **UNIQUE** | (user_id, score_date) | one record per user per day |

> **Score calculation**: `score = SUM(habit.current_streak)` for each completed habit on that date. Per CLAUDE.md: *"total day score is equal to the addition of all the existing streaks"*.

---

### `posts`

A user's shared daily score on the Friend Feed. One post per daily_score.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| user_id | uuid NOT NULL FK → profiles | |
| daily_score_id | uuid NOT NULL FK → daily_scores | |
| caption | text | e.g. `"Almost a perfect day…"` |
| viable_day_streak | int NOT NULL DEFAULT 0 | consecutive viable days at time of posting (the streak shown on feed cards) |
| created_at | timestamptz DEFAULT now() | |

> **`viable_day_streak`**: The "18 day streak" shown on Feed cards. Computed from `daily_scores.is_viable_day` history and snapshotted at post creation time — so the feed card remains accurate even if future days break the streak.

---

### `post_completed_habits`

Snapshot of which habits were completed in a post. Denormalized so feed card chips (Run, Read, Water…) remain accurate after habit edits or deletes.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| post_id | uuid NOT NULL FK → posts | |
| habit_id | uuid NULLABLE FK → habits | nullable in case habit is deleted |
| habit_name | text NOT NULL | snapshot of name at post time |
| is_mvd | bool NOT NULL DEFAULT false | snapshot of MVD status at post time |

---

### `friendships`

Bidirectional friendship model with a pending/accepted state.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| requester_id | uuid NOT NULL FK → profiles | user who sent the request |
| addressee_id | uuid NOT NULL FK → profiles | user who received the request |
| status | text NOT NULL DEFAULT 'pending' | `'pending'` \| `'accepted'` |
| created_at | timestamptz DEFAULT now() | |
| **UNIQUE** | (requester_id, addressee_id) | prevents duplicate requests |

> To check if two users are friends, query for an `accepted` row where either `(requester_id = A AND addressee_id = B)` or `(requester_id = B AND addressee_id = A)`.

---

### `hypes`

🔥 Hype reactions on posts. One per user per post.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| post_id | uuid NOT NULL FK → posts | |
| user_id | uuid NOT NULL FK → profiles | |
| created_at | timestamptz DEFAULT now() | |
| **UNIQUE** | (post_id, user_id) | one hype per user per post |

---

### `replies`

Comments on posts.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK DEFAULT gen_random_uuid() | |
| post_id | uuid NOT NULL FK → posts | |
| user_id | uuid NOT NULL FK → profiles | |
| content | text NOT NULL | |
| created_at | timestamptz DEFAULT now() | |

---

## Key Design Decisions

1. **`current_streak` cached on `habits`** — avoids recomputing streak from `habit_completions` on every render. A DB trigger or Supabase Edge Function updates this when a completion is inserted or when a scheduled job detects a missed day.

2. **`viable_day_streak` snapshotted on `posts`** — the consecutive viable-day streak shown on Feed cards is captured at post creation time, so it remains accurate even after future days break the streak.

3. **Daily Score = sum of completed habit streaks** — per CLAUDE.md spec: *"total day score is equal to the addition of all the existing streaks"*. `max_score` = sum of streaks for all active habits (used to fill the progress bar).

4. **`post_completed_habits.habit_name` is denormalized** — feed card habit chips must survive habit renames and deletes. Both `habit_name` and `is_mvd` are snapshotted at post time.

5. **Profile stats are computed, not stored** — Best Streak, High Score, and Friend Count are derived from other tables to avoid stale data.

6. **`user_id` denormalized on `habit_completions`** — simplifies RLS policies and avoids a join to `habits` on every completion query.

---

## Entity Relationship Summary

```
auth.users
    └── profiles
            ├── habits
            │       └── habit_completions
            ├── daily_scores
            │       └── posts
            │               ├── post_completed_habits
            │               ├── hypes
            │               └── replies
            └── friendships
```

---

## Next Steps (before creating Supabase tables)

- [ ] Confirm schema with team
- [ ] Write RLS policies for each table
- [ ] Write DB trigger / Edge Function for `current_streak` update logic
- [ ] Write Edge Function for `viable_day_streak` computation at post time
- [ ] Seed with test data for UI development
