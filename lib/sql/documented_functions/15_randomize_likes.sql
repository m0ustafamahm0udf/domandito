-- 1. Function and DO block to update PREVIOUS questions with random likes (thousands)
-- This updates likes_count for existing answered questions by the specific user.

-- Function to generate a random number between 1000 and 9999 (or higher)
CREATE OR REPLACE FUNCTION get_random_likes_count() 
RETURNS INT AS $$
BEGIN
  -- Returns a random number between 1000 and 5000 (adjust max as needed)
  RETURN floor(random() * (5000 - 1000 + 1) + 1000)::int;
END;
$$ LANGUAGE plpgsql;

-- Execute update for existing posts
DO $$
BEGIN
  UPDATE questions
  SET likes_count = get_random_likes_count()
  WHERE receiver_id = 'bf4ff112-46b7-4bd8-807c-e0547630a104'::uuid
  AND answered_at IS NOT NULL
  AND is_deleted = FALSE;
END;
$$;


-- 2. Trigger to automatically set random likes when THIS user answers a new question.

CREATE OR REPLACE FUNCTION set_random_likes_for_specific_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the update is setting 'answered_at' (meaning it's being answered now)
  -- AND the receiver (answerer) is the specific user.
  IF NEW.answered_at IS NOT NULL 
     AND OLD.answered_at IS NULL 
     AND NEW.receiver_id = 'bf4ff112-46b7-4bd8-807c-e0547630a104'::uuid THEN
     
     NEW.likes_count := get_random_likes_count();
     
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists to avoid errors on re-run
DROP TRIGGER IF EXISTS trigger_random_likes_on_answer ON questions;

CREATE TRIGGER trigger_random_likes_on_answer
BEFORE UPDATE ON questions
FOR EACH ROW
WHEN (OLD.answered_at IS NULL AND NEW.answered_at IS NOT NULL AND NEW.receiver_id = 'bf4ff112-46b7-4bd8-807c-e0547630a104'::uuid)
EXECUTE FUNCTION set_random_likes_for_specific_user();
