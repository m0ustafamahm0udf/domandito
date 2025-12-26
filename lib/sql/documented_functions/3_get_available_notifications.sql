-- حل مشكلة التعارض (PGRST203)
DROP FUNCTION IF EXISTS public.get_available_notifications(text, integer, integer);

-- النسخة المحسنة مع فلترة البلوك (مع الحفاظ على الأسئلة المجهولة)
CREATE OR REPLACE FUNCTION public.get_available_notifications(p_user_id uuid, p_limit integer, p_offset integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_blocked_ids uuid[];
begin
  -- 1. Get Blocked IDs
  select array_agg(uid)
  into v_blocked_ids
  from (
    select blocked_id as uid from blocks where blocker_id = p_user_id
    union
    select blocker_id as uid from blocks where blocked_id = p_user_id
  ) as combined_blocks;

  return (
    select json_agg(t)
    from (
      select 
        n.*,
        json_build_object(
          'id', u.id,
          'name', u.name,
          'username', u.username,
          'image', u.image,
          'is_verified', u.is_verified
        ) as sender
      from notifications n
      join users u on n.sender_id = u.id
      left join questions q on n.entity_id = q.id::text and n.type = 'question'
      where n.user_id = p_user_id
        -- Filter 1: Logic for showing questions only if unanswered
        and (
          n.type != 'question'
          or (n.type = 'question' and q.answered_at is null)
        )
        -- Filter 2: Block Logic (Hide notification if sender is blocked, EXCEPT anonymous questions)
        and (
             v_blocked_ids is null 
             or (n.type = 'question' and q.is_anonymous = true)
             or not (n.sender_id = any(v_blocked_ids))
        )
      order by n.created_at desc
      limit p_limit
      offset p_offset
    ) t
  );
end;
$function$
