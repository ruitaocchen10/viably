profiles - id, username, avatar_url, created_at
habits - id, user_id, name (character limit?), description, icon, is_mvd, is_active, current_streak, created_at
habit_completions - id, habit_id, user_id, completed_date, created_at
daily_scores - id, user_id, score_date, score (sum of current_streak for completed habits), max_score (sum of current_streak for all active habits), is_viable_day, created_at
posts - id, user_id, daily_score_id, caption, viable_day_streak, created_at,
post_completed_habits - id, post_id, habit_id, habit_name
friendships - id, requester_id, addressee_id, status, created_at
hypes - id, post_id, user_id, created_at
replies - id, post_id, user_id, content, created_at
