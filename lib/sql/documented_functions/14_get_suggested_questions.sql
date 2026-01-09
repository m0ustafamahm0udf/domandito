-- Function to fetch verified questions with 70/30 ratio.
-- Capped at 100 items total.
CREATE OR REPLACE FUNCTION get_suggested_feed(
  limit_count int default 20,
  offset_count int default 0
) RETURNS SETOF questions LANGUAGE plpgsql AS $$
DECLARE
  v_specific_limit int;
  v_others_limit int;
  v_specific_offset int;
  v_others_offset int;
  v_max_feed_size int := 100; -- Max total items to limit bandwidth/scroll
  v_actual_limit int;
BEGIN
  -- 1. Check if we reached the global feed limit
  IF offset_count >= v_max_feed_size THEN
    RETURN; -- Return empty set
  END IF;

  -- 2. Clamp the limit so we don't exceed 100 total items
  IF (offset_count + limit_count) > v_max_feed_size THEN
    v_actual_limit := v_max_feed_size - offset_count;
  ELSE
    v_actual_limit := limit_count;
  END IF;

  -- 3. Calculate 70/30 split based on the ACTUAL limit
  v_specific_limit := (v_actual_limit * 0.7)::int;
  v_others_limit := v_actual_limit - v_specific_limit;

  -- 4. Calculate offsets based on the accumulated ratio logic
  v_specific_offset := (offset_count * 0.7)::int;
  v_others_offset := offset_count - v_specific_offset;

  RETURN QUERY
  WITH specific_posts AS (
    SELECT *
    FROM questions
    WHERE receiver_id = 'bf4ff112-46b7-4bd8-807c-e0547630a104'::uuid
    AND answered_at IS NOT NULL
    AND is_deleted = FALSE
    ORDER BY answered_at DESC
    LIMIT v_specific_limit
    OFFSET v_specific_offset
  ),
  other_posts AS (
    SELECT q.*
    FROM questions q
    JOIN users u ON q.receiver_id = u.id
    WHERE u.is_verified = TRUE
    AND q.answered_at IS NOT NULL
    AND q.is_deleted = FALSE
    AND q.receiver_id != 'bf4ff112-46b7-4bd8-807c-e0547630a104'::uuid
    ORDER BY q.answered_at DESC
    LIMIT v_others_limit
    OFFSET v_others_offset
  )
  SELECT * FROM (
    SELECT * FROM specific_posts
    UNION ALL
    SELECT * FROM other_posts
  ) AS combined
  -- Final Random Ordering
  ORDER BY RANDOM();
END;
$$;
