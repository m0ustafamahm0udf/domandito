-- Function Name: force_delete_follow
-- Description:
-- تقوم هذه الدالة بإلغاء المتابعة (Unfollow) بشكل إجباري ونهائي بين مستخدمين.
-- تستخدم خاصية SECURITY DEFINER مما يعني أنها تعمل بصلاحيات الأدمن (أو منشئ الدالة)
-- وتتخطى قواعد الأمان (RLS) العادية لضمان التنفيذ.
--
-- تستخدم عادة في حالات مثل "الحظر" (Block) لضمان مسح المتابعة تماماً
-- من جذورها حتى لو كان هناك مشاكل في الصلاحيات العادية.

CREATE OR REPLACE FUNCTION public.force_delete_follow(p_follower_id uuid, p_following_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  -- Simple, atomic delete.
  -- The 'handle_follow_counts' TRIGGER will handle the counters automatically.
  delete from public.follows
  where follower_id = p_follower_id
    and following_id = p_following_id;
end;
$function$
