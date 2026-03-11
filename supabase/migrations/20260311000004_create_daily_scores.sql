create table daily_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  score_date date not null,
  score int not null default 0,
  max_score int not null default 0,
  is_viable_day boolean not null default false,
  created_at timestamptz not null default now(),
  unique(user_id, score_date)
);

alter table daily_scores enable row level security;

create policy "users can manage own daily scores"
  on daily_scores for all using (auth.uid() = user_id);
