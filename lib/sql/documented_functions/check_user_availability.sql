-- Function Name: check_user_availability
-- Description:
-- وظيفتها فحص توفر بيانات التسجيل (الهاتف، اسم المستخدم، البريد) دفعة واحدة.
--
-- المشكلة الحالية:
-- صفحة التسجيل تقوم بـ 3 استعلامات منفصلة للتأكد من عدم تكرار البيانات.
--
-- الحل:
-- دالة واحدة تأخذ كل البيانات وترجع تقريراً مفصلاً.
--
-- المخرجات (JSON):
-- {
--   "phone_exists": true/false,
--   "username_exists": true/false,
--   "email_exists": true/false
-- }
--
-- ملاحظة ذكية:
-- الدالة تقبل p_exclude_user_id عشان لو المستخدم بيعدل بياناته، نستثني الـ ID بتاعه من الفحص.
-- (يعني عادي إنه يستخدم نفس رقم تليفونه هو، بس مش مسموح يستخدم رقم حد تاني).

CREATE OR REPLACE FUNCTION public.check_user_availability(
    p_phone text, 
    p_username text, 
    p_email text, 
    p_exclude_user_id text DEFAULT null
)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_exclude_uuid uuid;
  v_phone_exists boolean;
  v_username_exists boolean;
  v_email_exists boolean;
begin
  -- 1. Safe Casting
  begin
    v_exclude_uuid := nullif(p_exclude_user_id, '')::uuid;
  exception when others then
    v_exclude_uuid := null;
  end;

  -- 2. Check Phone (Only if provided)
  if p_phone is not null and p_phone != '' then
    select exists(
      select 1 from users 
      where phone = p_phone 
      and (v_exclude_uuid is null or id != v_exclude_uuid)
    ) into v_phone_exists;
  else
    v_phone_exists := false;
  end if;

  -- 3. Check Username
  select exists(
    select 1 from users 
    where username = p_username 
    and (v_exclude_uuid is null or id != v_exclude_uuid)
  ) into v_username_exists;

  -- 4. Check Email
  select exists(
    select 1 from users 
    where email = p_email 
    and (v_exclude_uuid is null or id != v_exclude_uuid)
  ) into v_email_exists;

  -- 5. Return Report
  return json_build_object(
    'phone_exists', v_phone_exists,
    'username_exists', v_username_exists,
    'email_exists', v_email_exists
  );
end;
$function$
