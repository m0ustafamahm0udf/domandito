-- Function Name: get_profile_questions
-- Description:
-- وظيفتها جلب أسئلة البروفايل "جاهزة للعرض" بطلب واحد.
--
-- المشاكل الحالية:
-- التطبيق يجلب الأسئلة خام، ثم يقوم بـ Loop للتأكد من اللايكات، ثم يرتب "المثبت" يدوياً.
-- هذا يستهلك وقتاً وذاكرة في الموبايل.
--
-- الحل (هذه الدالة):
-- 1. تجلب الأسئلة الخاصة بمستخدم معين (p_target_id).
-- 2. تتأكد أنها مجابة، غير محذوفة، وصاحبها مش محظور.
-- 3. ترتبها بذكاء: الأسئلة المثبتة أولاً، ثم حسب تاريخ الإجابة.
-- 4. تحسب حقل "is_liked" لكل سؤال (لو أنا مسجل دخول).
--
-- النتيجة:
-- قائمة جاهزة للرسم مباشرة في الـ ListView بدون أي معالجة إضافية.

DROP FUNCTION IF EXISTS public.get_profile_questions(text, text, integer, integer);

CREATE OR REPLACE FUNCTION public.get_profile_questions(
    p_my_id text,       -- مين اللي بيفتح البروفايل (عشان اللايك والبلوك)
    p_target_id text,   -- صاحب البروفايل
    p_limit integer,    -- عدد الأسئلة (Pagination)
    p_offset integer    -- البداية
)
 RETURNS TABLE(
    id text, 
    created_at timestamp with time zone, 
    title text, 
    answer_text text, 
    images text[], 
    video_url text,    -- Added
    thumbnail_url text, -- Added
    media_type text,   -- Added
    is_anonymous boolean, 
    is_pinned boolean, 
    likes_count bigint, 
    answered_at timestamp with time zone, 
    sender json, 
    receiver json, -- بنرجعه عشان التطبيق محتاجه (رغم إنه معروف)
    is_liked boolean
 )
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_my_uuid uuid;
  v_target_uuid uuid;
  v_blocked_ids uuid[];
begin
  -- 1. Safe Casting
  begin
    v_my_uuid := nullif(p_my_id, '')::uuid;
    v_target_uuid := nullif(p_target_id, '')::uuid;
  exception when others then
    return;
  end;

  -- 2. Get Blocked IDs (لو أنا مسجل دخول، هات قايمتي السواء عشان مشوفش أسئلة منهم)
  if v_my_uuid is not null then
    select array_agg(uid)
    into v_blocked_ids
    from (
      select blocked_id as uid from blocks where blocker_id = v_my_uuid
      union
      select blocker_id as uid from blocks where blocked_id = v_my_uuid
    ) as combined_blocks;
  end if;

  return query
  select 
    q.id::text,
    q.created_at,
    q.title,
    q.answer_text,
    q.images,
    q.video_url,  -- Added
    q.thumbnail_url, -- Added
    q.media_type, -- Added
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
    ) as sender,
    -- Construct Receiver JSON (Fixed target user)
    json_build_object(
      'id', r.id,
      'name', r.name,
      'username', r.username,
      'image', r.image,
      'is_verified', r.is_verified,
      'token', r.token
    ) as receiver,
    -- Like Check
    exists (
      select 1 from likes l 
      where l.question_id = q.id 
      and l.user_id = v_my_uuid 
    ) as is_liked

  from questions q
  join users s on q.sender_id = s.id
  join users r on q.receiver_id = r.id
  where 
    q.receiver_id = v_target_uuid
    and q.is_deleted = false
    and q.answered_at is not null
    -- Filter blocked users (sender), EXCEPT if anonymous
    and (v_blocked_ids is null or q.is_anonymous = true or not (q.sender_id = any(v_blocked_ids)))
  order by 
    q.is_pinned desc,     -- المثبت أولاً
    q.answered_at desc    -- الأحدث إجابة
  limit p_limit
  offset p_offset;
end;
$function$
