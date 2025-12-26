-- حل مشكلة التعارض (PGRST203)
-- نقوم بمسح النسخة التي تسببت في الحيرة (التي تقبل text)
DROP FUNCTION IF EXISTS public.get_available_notifications(text, integer, integer);

-- ونعيد تأكيد إنشاء النسخة التي اخترتها (التي تقبل uuid وترجع json)
CREATE OR REPLACE FUNCTION public.get_available_notifications(p_user_id uuid, p_limit integer, p_offset integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
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
        -- Filter: Show logic
        and (
          n.type != 'question'  -- Always show non-question notifications
          or (n.type = 'question' and q.answered_at is null) -- Only show unanswered questions
        )
      order by n.created_at desc
      limit p_limit
      offset p_offset
    ) t
  );
end;
$function$
