-- Function: mark_all_notifications_read
-- Description: Marks all unread notifications for a specific user as read
-- Parameters:
--   p_user_id: UUID of the user whose notifications should be marked as read
-- Returns: Count of notifications that were updated

CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(p_user_id text)
RETURNS integer
LANGUAGE plpgsql
AS $function$
DECLARE
  v_user_uuid uuid;
  v_updated_count integer;
BEGIN
  -- Convert text user_id to UUID
  BEGIN
    v_user_uuid := p_user_id::uuid;
  EXCEPTION
    WHEN invalid_text_representation THEN
      RAISE EXCEPTION 'Invalid user ID format: %', p_user_id;
  END;

  -- Update all unread notifications for the user
  WITH updated AS (
    UPDATE notifications
    SET is_read = true
    WHERE user_id = v_user_uuid
      AND is_read = false
    RETURNING id
  )
  SELECT COUNT(*)::integer INTO v_updated_count FROM updated;

  -- Return the count of updated notifications
  RETURN v_updated_count;
END;
$function$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.mark_all_notifications_read(text) TO authenticated;

-- Example usage:
-- SELECT mark_all_notifications_read('user-uuid-here');
