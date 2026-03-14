-- Social features schema migration
-- Run this in the Supabase SQL editor

-- ============================================================
-- posts
-- ============================================================
create table if not exists posts (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid references auth.users not null,
    score_date  date not null,
    score       int not null,
    caption     text,
    created_at  timestamptz default now(),
    unique(user_id, score_date)
);

-- ============================================================
-- post_completed_habits (snapshot at post time)
-- ============================================================
create table if not exists post_completed_habits (
    id          uuid primary key default gen_random_uuid(),
    post_id     uuid references posts on delete cascade,
    habit_id    uuid references habits on delete cascade,
    habit_name  text not null,
    habit_icon  text
);

-- ============================================================
-- friendships (bidirectional, one row per pair)
-- ============================================================
create table if not exists friendships (
    id            uuid primary key default gen_random_uuid(),
    requester_id  uuid references auth.users not null,
    addressee_id  uuid references auth.users not null,
    status        text not null default 'pending',  -- 'pending' | 'accepted'
    created_at    timestamptz default now(),
    unique(requester_id, addressee_id)
);

-- ============================================================
-- hypes (one per user per post)
-- ============================================================
create table if not exists hypes (
    id          uuid primary key default gen_random_uuid(),
    post_id     uuid references posts on delete cascade not null,
    user_id     uuid references auth.users not null,
    created_at  timestamptz default now(),
    unique(post_id, user_id)
);

-- ============================================================
-- replies
-- ============================================================
create table if not exists replies (
    id          uuid primary key default gen_random_uuid(),
    post_id     uuid references posts on delete cascade not null,
    user_id     uuid references auth.users not null,
    content     text not null,
    created_at  timestamptz default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table posts enable row level security;
alter table post_completed_habits enable row level security;
alter table friendships enable row level security;
alter table hypes enable row level security;
alter table replies enable row level security;

-- posts: anyone authenticated can read; own rows only for write
create policy "posts: authenticated read"
    on posts for select to authenticated using (true);

create policy "posts: own insert"
    on posts for insert to authenticated
    with check (auth.uid() = user_id);

create policy "posts: own delete"
    on posts for delete to authenticated
    using (auth.uid() = user_id);

create policy "posts: own update"
    on posts for update to authenticated
    using (auth.uid() = user_id);

-- post_completed_habits: readable by all authenticated; write via post ownership
create policy "post_habits: authenticated read"
    on post_completed_habits for select to authenticated using (true);

create policy "post_habits: insert via post ownership"
    on post_completed_habits for insert to authenticated
    with check (
        exists (
            select 1 from posts
            where posts.id = post_id
              and posts.user_id = auth.uid()
        )
    );

create policy "post_habits: delete via post ownership"
    on post_completed_habits for delete to authenticated
    using (
        exists (
            select 1 from posts
            where posts.id = post_id
              and posts.user_id = auth.uid()
        )
    );

-- friendships: own rows only
create policy "friendships: own select"
    on friendships for select to authenticated
    using (auth.uid() = requester_id or auth.uid() = addressee_id);

create policy "friendships: requester insert"
    on friendships for insert to authenticated
    with check (auth.uid() = requester_id);

create policy "friendships: addressee update (accept)"
    on friendships for update to authenticated
    using (auth.uid() = addressee_id);

create policy "friendships: either party delete"
    on friendships for delete to authenticated
    using (auth.uid() = requester_id or auth.uid() = addressee_id);

-- hypes: anyone reads; own rows for write
create policy "hypes: authenticated read"
    on hypes for select to authenticated using (true);

create policy "hypes: own insert"
    on hypes for insert to authenticated
    with check (auth.uid() = user_id);

create policy "hypes: own delete"
    on hypes for delete to authenticated
    using (auth.uid() = user_id);

-- replies: anyone reads; own rows for write
create policy "replies: authenticated read"
    on replies for select to authenticated using (true);

create policy "replies: own insert"
    on replies for insert to authenticated
    with check (auth.uid() = user_id);

create policy "replies: own delete"
    on replies for delete to authenticated
    using (auth.uid() = user_id);
