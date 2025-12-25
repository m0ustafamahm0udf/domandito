-- Function to get notifications with sender details efficiently
-- OPTIMIZATION PHASE 2:
-- 1. Uses SECURITY DEFINER to bypass expensive RLS checks (Performance Boost).
-- 2. Uses auth.uid() for secure server-side user identification.
-- 3. Added index for unread count.

-- HOW TO USE:
-- 1. Run these INDEX commands in Supabase SQL Editor:
--    CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
--    CREATE INDEX IF NOT EXISTS idx_notifications_sender ON notifications(sender_id);
--    CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id) WHERE is_read = false;

-- 2. Run this function definition.

DROP FUNCTION IF EXISTS get_available_notifications(text, int, int); -- Cleanup old if exists
DROP FUNCTION IF EXISTS get_available_notifications(text, int, int); -- Cleanup previous version

-- Note: We removed p_user_id from parameters
CREATE OR REPLACE FUNCTION get_available_notifications(
  p_limit int,
  p_offset int
)
RETURNS TABLE (
  id text,
  created_at timestamptz,
  user_id text,
  sender_id text,
  type text,
  entity_id text,
  title text,
  body text,
  is_read boolean,
  sender json
)
LANGUAGE plpgsql
SECURITY DEFINER -- bypassing RLS for speed
SET search_path = public -- security best practice
AS $$
DECLARE
  v_user_uuid uuid;
BEGIN
  -- Get current user ID securely from session
  v_user_uuid := auth.uid();

  -- If no user logged in, return empty
  IF v_user_uuid IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    n.id::text,
    n.created_at,
    n.user_id::text,
    n.sender_id::text,
    n.type,
    n.entity_id::text,
    n.title,
    n.body,
    n.is_read,
    -- Sender JSON
    CASE WHEN n.sender_id IS NOT NULL THEN
      json_build_object(
        'id', u.id,
        'name', u.name,
        'username', u.username,
        'image', u.image,
        'is_verified', u.is_verified,
        'bio', COALESCE(u.bio, ''),
        'followers_count', COALESCE(u.followers_count, 0),
        'following_count', COALESCE(u.following_count, 0),
        'posts_count', COALESCE(u.posts_count, 0)
      )
    ELSE
      NULL
    END as sender
  FROM notifications n
  LEFT JOIN users u ON n.sender_id = u.id
  WHERE n.user_id = v_user_uuid
  ORDER BY n.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;
