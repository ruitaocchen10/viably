-- When a habit is hard-deleted, preserve the snapshot in post_completed_habits
-- (habit_name and habit_icon) by setting habit_id to null instead of cascade deleting the row.
alter table post_completed_habits
  drop constraint post_completed_habits_habit_id_fkey,
  add constraint post_completed_habits_habit_id_fkey
    foreign key (habit_id) references habits(id) on delete set null;
