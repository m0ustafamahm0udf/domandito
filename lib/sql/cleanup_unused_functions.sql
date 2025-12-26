-- Clean up unused functions from the database

-- 1. Drop the unused version of get_home_feed
DROP FUNCTION IF EXISTS public.get_home_feed_v2(text, int, int);

-- 2. Drop the unused toggle_block_user function (logic is handled in Dart currently)
DROP FUNCTION IF EXISTS public.toggle_block_user(uuid, uuid);
