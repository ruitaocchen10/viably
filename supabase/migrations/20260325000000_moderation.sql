-- Moderation: blocks and reports tables

-- ============================================================
-- blocks
-- ============================================================
create table if not exists blocks (
    id          uuid primary key default gen_random_uuid(),
    blocker_id  uuid not null references auth.users(id) on delete cascade,
    blocked_id  uuid not null references auth.users(id) on delete cascade,
    created_at  timestamptz default now(),
    unique(blocker_id, blocked_id)
);

-- ============================================================
-- reports
-- ============================================================
create table if not exists reports (
    id               uuid primary key default gen_random_uuid(),
    reporter_id      uuid not null references auth.users(id) on delete cascade,
    reported_user_id uuid not null references auth.users(id) on delete cascade,
    content_type     text not null check (content_type in ('post', 'reply')),
    content_id       uuid not null,
    reason           text not null check (reason in ('spam', 'harassment', 'inappropriate', 'other')),
    status           text not null default 'pending' check (status in ('pending', 'reviewed')),
    created_at       timestamptz default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table blocks enable row level security;
alter table reports enable row level security;

-- blocks: users manage their own block list
create policy "blocks: own select"
    on blocks for select to authenticated
    using (auth.uid() = blocker_id);

create policy "blocks: own insert"
    on blocks for insert to authenticated
    with check (auth.uid() = blocker_id);

create policy "blocks: own delete"
    on blocks for delete to authenticated
    using (auth.uid() = blocker_id);

-- reports: insert only (reporters cannot read moderation status)
create policy "reports: own insert"
    on reports for insert to authenticated
    with check (auth.uid() = reporter_id);

-- ============================================================
-- Grants
-- ============================================================

grant select, insert, delete on blocks to authenticated;
grant insert on reports to authenticated;
