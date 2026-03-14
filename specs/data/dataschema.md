profiles - id, username, display_name, avatar_url, created_at
habits - id, user_id, name, description, icon, is_mvd, is_active, current_streak, created_at
habit_completions - id, habit_id, user_id, completed_date, created_at, UNIQUE(habit_id, completed_date)
daily_scores - id, user_id, score_date, score (sum of current_streak for completed habits), max_score (sum of current_streak for all active habits), is_viable_day, created_at, UNIQUE(user_id, score_date)
posts - id, user_id, score_date, score, caption, created_at, UNIQUE(user_id, score_date)
post_completed_habits - id, post_id, habit_id, habit_name, habit_icon
friendships - id, requester_id, addressee_id, status ('pending'|'accepted'), created_at, UNIQUE(requester_id, addressee_id)
hypes - id, post_id, user_id, created_at, UNIQUE(post_id, user_id)
replies - id, post_id, user_id, content, created_at
