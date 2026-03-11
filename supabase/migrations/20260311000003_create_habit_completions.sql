create table habit_completions (
  id uuid primary key default gen_random_uuid(),
  habit_id uuid references habits(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  completed_date date not null,
  created_at timestamptz not null default now(),
  unique(habit_id, completed_date)
);

alter table habit_completions enable row level security;

create policy "users can manage own completions"
  on habit_completions for all using (auth.uid() = user_id);
