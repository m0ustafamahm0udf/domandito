-- Function Name: get_unread_notifications_count
-- Description:
-- تحسب هذه الدالة عدد الإشعارات "الحقيقية" غير المقروءة.
--
-- التعديلات الحديثة:
-- 1. تغيير الباراميتر ليقبل (text) بدلاً من (uuid) ليتوافق تماماً مع ما يرسله التطبيق (Firebase ID).
-- 2. التحويل الآمن (Safe Casting) داخل الدالة لمنع أي أخطاء إذا كان النص غير صالح.
--
-- الفائدة:
-- - منع حدوث أخطاء "Invalid input syntax for type uuid" التي قد تحدث أحياناً
--   إذا أرسل التطبيق نصاً فارغاً أو غير صالح بالخطأ.
-- - توحيد شكل الدوال في المشروع (Consistency).

-- أولاً: حذف النسخة القديمة لتجنب التعارض (Overloading Conflict)
DROP FUNCTION IF EXISTS public.get_unread_notifications_count(uuid);

-- ثانياً: إنشاء النسخة المحسنة
CREATE OR REPLACE FUNCTION public.get_unread_notifications_count(p_user_id text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_user_uuid uuid;
BEGIN
  -- 1. محاولة تحويل النص إلى UUID بأمان
  BEGIN
    v_user_uuid := p_user_id::uuid;
  EXCEPTION WHEN invalid_text_representation THEN
    RETURN 0; -- إذا كان المعرف غير صالح، نرجع 0 بدلاً من الانهيار (Crash)
  END;

  -- 2. تنفيذ العد
  return (
    select count(*)
    from notifications n
    left join questions q on n.entity_id = q.id::text and n.type = 'question'
    where n.user_id = v_user_uuid
      and n.is_read = false
      and (
        n.type != 'question' 
        or (n.type = 'question' and q.answered_at is null)
      )
  );
END;
$function$
