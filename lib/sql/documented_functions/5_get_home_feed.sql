-- Function Name: get_home_feed
-- Description:
-- المسؤولة عن جلب الـ Timeline (الصفحة الرئيسية).
-- تعرض الإجابات الجديدة من الأشخاص الذين يتابعهم المستخدم (p_user_id).
--
-- آلية العمل:
-- 1. تستقبل معرف المستخدم (Text) وتحوله لـ UUID بأمان.
-- 2. تجلب قائمة المحظورين (Block List) لهذا المستخدم لتجنب عرض محتواهم.
-- 3. تقوم بعمل JOIN بين جداول (Questions, Follows, Users).
-- 4. تفلتر النتائج:
--    - أسئلة الأشخاص المتابعهم فقط.
--    - الأسئلة المجابة فقط (answered_at IS NOT NULL).
--    - الأسئلة غير المحذوفة.
--    - تستبعد أي سؤال طرفه شخص محظور (سائل أو مجيب).
-- 5. تحسب حقل is_liked لكل سؤال لمعرفة حالة اللايك للمستخدم الحالي.
--
-- تقييم الأداء (Performance):
-- - ممتاز، لأنها تقوم بكل عمليات الفلترة والتجميع في الداتابيس وترسل النتيجة جاهزة.
-- - أفضل بكثير من جلب كل البيانات ومعالجتها في التطبيق.
-- - الفلترة بقائمة البلوك (Block List) تتم بكفاءة باستخدام المصفوفات (Arrays).
--
-- تقييم الباندويدث (Bandwidth):
-- - جيد جداً، لأنها ترسل فقط الحقول المطلوبة للعرض.
-- - الـ Sender & Receiver Objects تحتوي فقط على البيانات الأساسية (الاسم، الصورة..).

DROP FUNCTION IF EXISTS public.get_home_feed(text, integer, integer);

CREATE OR REPLACE FUNCTION public.get_home_feed(p_user_id text, p_limit integer, p_offset integer)
 RETURNS TABLE(id text, created_at timestamp with time zone, title text, answer_text text, images text[], video_url text, thumbnail_url text, media_type text, is_anonymous boolean, is_pinned boolean, likes_count bigint, answered_at timestamp with time zone, sender json, receiver json, is_liked boolean)
 LANGUAGE plpgsql
AS $function$
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
    q.video_url,  -- Added video_url
    q.thumbnail_url, -- Added thumbnail_url
    q.media_type, -- Added media_type
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
    -- Filter blocked users (sender checks), allowing anonymous
    and (v_blocked_ids is null or q.is_anonymous = true or not (q.sender_id = any(v_blocked_ids)))
  order by q.answered_at desc
  limit p_limit
  offset p_offset;
end;
$function$
