-- Function to get home feed for a user
-- Returns questions answered by people the user follows

-- HOW TO USE: 
-- 1. FIRST, ensure you ran 'lib/sql/fix_database_types.sql' to convert columns to UUID.
-- 2. Run this SQL in Supabase to create the optimized function.

-- Drop potential old versions to avoid conflicts
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
  sender_id text,      
  receiver_id text,    
  sender json,
  receiver json,
  is_liked boolean
)
language plpgsql
as $$
declare
  v_user_uuid uuid;      -- Optimized: Native UUID for index usage
  v_blocked_ids uuid[];  -- Optimized: Native UUID array
begin
  -- 1. Cast input to UUID safely
  begin
    v_user_uuid := p_user_id::uuid;
  exception when invalid_text_representation then
    return; -- Return empty if invalid ID provided
  end;

  -- 2. Get Blocked IDs (Both directions: I blocked them OR They blocked me)
  -- This ensures:
  -- A. I don't see content from people I blocked.
  -- B. I don't see content from people who blocked me (Mutual visibility restriction).
  select array_agg(uid)
  into v_blocked_ids
  from (
    select blocked_id as uid from blocks where blocker_id = v_user_uuid
    union
    select blocker_id as uid from blocks where blocked_id = v_user_uuid
  ) as combined_blocks; 

  return query
  select 
    q.id::text, -- Return as text for Flutter compatibility
    q.created_at,
    q.title,
    q.answer_text,
    q.images,
    q.is_anonymous,
    q.is_pinned,
    q.likes_count, 
    q.answered_at,
    q.sender_id::text,
    q.receiver_id::text,
    -- Construct Sender JSON
    json_build_object(
      'id', s.id,
      'name', s.name,
      'username', s.username,
      'image', s.image,
      'is_verified', s.is_verified
    ) as sender,
    -- Construct Receiver JSON
    json_build_object(
      'id', r.id,
      'name', r.name,
      'username', r.username,
      'image', r.image,
      'is_verified', r.is_verified,
      'token', r.token 
    ) as receiver,
    -- Like Check (Using INDEX on user_id + question_id)
    exists (
      select 1 from likes l 
      where l.question_id = q.id 
      and l.user_id = v_user_uuid 
    ) as is_liked

  from questions q
  -- Optimized Joins (Index friendly)
  join follows f on f.following_id = q.receiver_id 
  join users s on q.sender_id = s.id
  join users r on q.receiver_id = r.id
  where 
    -- Main Filter (Using INDEX on follower_id)
    f.follower_id = v_user_uuid 
    and q.is_deleted = false
    and q.answered_at is not null
    -- Block Filters (Efficient UUID comparison)
    and (v_blocked_ids is null or not (q.receiver_id = any(v_blocked_ids)))
    and (v_blocked_ids is null or not (q.sender_id = any(v_blocked_ids)))
  order by q.answered_at desc
  limit p_limit
  offset p_offset;
end;
$$;
