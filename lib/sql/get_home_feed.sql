-- Function to get home feed for a user
-- Returns questions answered by people the user follows

-- HOW TO USE: 
-- 1. FIRST, ensure you ran 'lib/sql/fix_database_types.sql' to convert columns to UUID.
-- 2. Run these INDEX commands in Supabase SQL Editor for maximum speed:
--    CREATE INDEX IF NOT EXISTS idx_questions_feed ON questions(receiver_id, answered_at DESC) WHERE is_deleted = false AND answered_at IS NOT NULL;
--    CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id, following_id);
--    CREATE INDEX IF NOT EXISTS idx_likes_lookup ON likes(question_id, user_id);

-- 3. Run this SQL in Supabase to create the optimized function.

drop function if exists get_home_feed(uuid, int, int);
drop function if exists get_home_feed(text, int, int);

create or replace function get_home_feed(
  p_user_id text, -- We accept text from Flutter, but will cast it locally
  p_limit int,
  p_offset int
)
returns table (
  id text,             
  created_at timestamptz,
  title text,
  answer_text text,
  images text[],
  is_anonymous boolean,
  is_pinned boolean,
  likes_count bigint,
  answered_at timestamptz,
  sender json,
  receiver json,
  is_liked boolean
)
language plpgsql
as $$
declare
  v_user_uuid uuid;
  v_blocked_ids uuid[];
begin
  -- 1. Cast input to UUID safely
  begin
    v_user_uuid := p_user_id::uuid;
  exception when invalid_text_representation then
    return; -- Return empty if invalid ID provided
  end;

  -- 2. Get Blocked IDs
  select array_agg(uid)
  into v_blocked_ids
  from (
    select blocked_id as uid from blocks where blocker_id = v_user_uuid
    union
    select blocker_id as uid from blocks where blocked_id = v_user_uuid
  ) as combined_blocks; 

  return query
  select 
    q.id::text,
    q.created_at,
    q.title,
    q.answer_text,
    q.images,
    q.is_anonymous,
    q.is_pinned,
    q.likes_count, 
    q.answered_at,
    -- Construct Sender JSON
    json_build_object(
      'id', s.id,
      'name', s.name,
      'username', s.username,
      'image', s.image,
      'is_verified', s.is_verified
      -- Sender token not strictly needed for feed interactions yet
    ) as sender,
    -- Construct Receiver JSON
    json_build_object(
      'id', r.id,
      'name', r.name,
      'username', r.username,
      'image', r.image,
      'is_verified', r.is_verified,
      'token', r.token -- RESTORED: Needed for client-side like notifications
    ) as receiver,
    -- Like Check
    exists (
      select 1 from likes l 
      where l.question_id = q.id 
      and l.user_id = v_user_uuid 
    ) as is_liked

  from questions q
  join follows f on f.following_id = q.receiver_id 
  join users s on q.sender_id = s.id
  join users r on q.receiver_id = r.id
  where 
    f.follower_id = v_user_uuid 
    and q.is_deleted = false
    and q.answered_at is not null
    and (v_blocked_ids is null or not (q.receiver_id = any(v_blocked_ids)))
    and (v_blocked_ids is null or not (q.sender_id = any(v_blocked_ids)))
  order by q.answered_at desc
  limit p_limit
  offset p_offset;
end;
$$;
