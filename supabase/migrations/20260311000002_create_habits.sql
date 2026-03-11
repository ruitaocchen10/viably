create table habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name varchar(50) not null,
  icon text,
  is_mvd boolean not null default false,
  is_active boolean not null default true,
  current_streak int not null default 0,
  created_at timestamptz not null default now()
);

alter table habits enable row level security;

create policy "users can manage own habits"
  on habits for all using (auth.uid() = user_id);
