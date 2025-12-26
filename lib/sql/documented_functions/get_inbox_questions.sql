-- Function Name: get_inbox_questions
-- Description:
-- وظيفتها جلب "صندوق الوارد" (الأسئلة الجديدة التي لم تتم الإجابة عليها).
--
-- التحسينات:
-- 1. التأكد من أن السؤال لم يُجب عليه (answered_at IS NULL).
-- 2. التأكد من أن السائل ليس محظوراً (Smart Filtering).
-- 3. الترتيب من الأحدث للأقدم.
--
-- ملاحظة هامة:
-- هذه الدالة مخصصة للمستخدم نفسه (p_my_id) ليرى أسئلته الواردة.

CREATE OR REPLACE FUNCTION public.get_inbox_questions(
    p_my_id text,       -- معرفي أنا (المستلم)
    p_limit integer, 
    p_offset integer
)
 RETURNS TABLE(
    id text, 
    created_at timestamp with time zone, 
    title text, 
    is_anonymous boolean, 
    sender json, 
    receiver json
 )
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_my_uuid uuid;
  v_blocked_ids uuid[];
begin
  -- 1. Safe Casting
  begin
    v_my_uuid := nullif(p_my_id, '')::uuid;
  exception when others then
    return;
  end;

  -- 2. Get Blocked IDs (عشان مشوفش أسئلة من ناس أنا عملتلهم بلوك)
  select array_agg(uid)
  into v_blocked_ids
  from (
    select blocked_id as uid from blocks where blocker_id = v_my_uuid
    union
    select blocker_id as uid from blocks where blocked_id = v_my_uuid
  ) as combined_blocks;

  return query
  select 
    q.id::text,
    q.created_at,
    q.title,
    q.is_anonymous,
    -- Sender JSON
    json_build_object(
      'id', s.id,
      'name', s.name,
      'username', s.username,
      'image', s.image,
      'is_verified', s.is_verified
    ) as sender,
    -- Receiver JSON (Me) - بنرجعه برضه عشان التوافق مع المودل في الدارت
    json_build_object(
      'id', r.id,
      'name', r.name,
      'username', r.username,
      'image', r.image,
      'is_verified', r.is_verified,
      'token', r.token
    ) as receiver

  from questions q
  join users s on q.sender_id = s.id
  join users r on q.receiver_id = r.id
  where 
    q.receiver_id = v_my_uuid
    and q.is_deleted = false
    and q.answered_at is null -- شرط أساسي: لم تتم الإجابة
    -- Filter blocked users
    and (v_blocked_ids is null or not (q.sender_id = any(v_blocked_ids)))
  order by q.created_at desc
  limit p_limit
  offset p_offset;
end;
$function$
