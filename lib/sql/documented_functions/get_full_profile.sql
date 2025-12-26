-- Function Name: get_full_profile
-- Description:
-- هذه الدالة "خارقة" (All-in-One) لصفحة البروفايل.
--
-- المشكلة الحالية:
-- التطبيق يقوم بعمل 6 طلبات منفصلة للسيرفر لفتح بروفايل واحد:
-- 1. getProfile (User Data)
-- 2. checkBlock (Me -> Him)
-- 3. checkBlock (Him -> Me)
-- 4. checkFollowing
-- 5. getQuestionsCount
--
-- الحل (هذه الدالة):
-- تقوم بكل هذه العمليات في طلب واحد فقط (1 Round Trip).
--
-- المخرجات (JSON):
-- ترجع JSON Object يحتوي على كل ما تحتاجه الشاشة:
-- {
--   "user": { ...data... },
--   "stats": { "followers": 10, "following": 5, "questions": 20 },
--   "relationship": {
--     "is_following": true,
--     "is_blocked_by_me": false,
--     "is_blocked_by_target": false
--   }
-- }
--
-- تقييم الأداء (Performance):
-- - نقلة نوعية في سرعة فتح البروفايل.
-- - تقليل الحمل على التطبيق (Client-Side) والسيرفر (Connection Overhead).

CREATE OR REPLACE FUNCTION public.get_full_profile(p_my_id text, p_target_id text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_my_uuid uuid;
  v_target_uuid uuid;
  v_user_data json;
  v_questions_count integer;
  v_is_following boolean;
  v_blocked_by_me boolean;
  v_blocked_by_target boolean;
begin
  -- 1. Safe Casting
  begin
    v_my_uuid := nullif(p_my_id, '')::uuid;
    v_target_uuid := nullif(p_target_id, '')::uuid;
  exception when others then
    -- If IDs are invalid, return null or handle gracefully
    return null;
  end;

  -- 2. Get User Data
  select row_to_json(u) into v_user_data
  from users u
  where id = v_target_uuid;

  if v_user_data is null then
    return null; -- User not found
  end if;

  -- 3. Get Relationship Status (Only if logged in)
  if v_my_uuid is not null and v_my_uuid != v_target_uuid then
    
    -- Check Following
    select exists(
      select 1 from follows 
      where follower_id = v_my_uuid and following_id = v_target_uuid
    ) into v_is_following;

    -- Check Blocking (Both directions)
    select 
      exists(select 1 from blocks where blocker_id = v_my_uuid and blocked_id = v_target_uuid),
      exists(select 1 from blocks where blocker_id = v_target_uuid and blocked_id = v_my_uuid)
    into v_blocked_by_me, v_blocked_by_target;
    
  else
    -- Viewing own profile or Guest
    v_is_following := false;
    v_blocked_by_me := false;
    v_blocked_by_target := false;
  end if;

  -- 4. Get Questions Count (Active Only)
  select count(*)
  into v_questions_count
  from questions
  where receiver_id = v_target_uuid
    and is_deleted = false
    and answered_at is not null;

  -- 5. Build Final JSON Response
  return json_build_object(
    'user', v_user_data,
    'stats', json_build_object(
      'questions_count', v_questions_count
      -- followers/following counts are already inside 'user' data thanks to our triggers
    ),
    'relationship', json_build_object(
      'is_me', (v_my_uuid = v_target_uuid),
      'is_following', v_is_following,
      'is_blocked_by_me', v_blocked_by_me,
      'is_blocked_by_target', v_blocked_by_target
    )
  );
end;
$function$
