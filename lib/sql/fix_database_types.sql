-- DATABASE SCHEMA FIX SCRIPT
-- This script converts all ID columns from 'text' to 'uuid' to match Supabase auth.users.
-- Run this in Supabase SQL Editor.

BEGIN; -- Start transaction (if one fails, all revert)

-- 1. Fix 'follows' table
ALTER TABLE follows
  ALTER COLUMN follower_id TYPE uuid USING follower_id::uuid,
  ALTER COLUMN following_id TYPE uuid USING following_id::uuid;

-- 2. Fix 'questions' table
ALTER TABLE questions
  ALTER COLUMN sender_id TYPE uuid USING sender_id::uuid,
  ALTER COLUMN receiver_id TYPE uuid USING receiver_id::uuid;
  -- Note: 'id' of questions is usually uuid by default, but good to check:
  -- ALTER COLUMN id TYPE uuid USING id::uuid; 

-- 3. Fix 'likes' table
ALTER TABLE likes
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid,
  ALTER COLUMN question_id TYPE uuid USING question_id::uuid;

-- 4. Fix 'blocks' table
ALTER TABLE blocks
  ALTER COLUMN blocker_id TYPE uuid USING blocker_id::uuid,
  ALTER COLUMN blocked_id TYPE uuid USING blocked_id::uuid;

COMMIT;

-- AFTER RUNNING THIS:
-- You can go back to using the "Efficient" version of get_home_feed code 
-- because now all columns are true UUIDs.
