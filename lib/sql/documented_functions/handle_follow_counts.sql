-- Function Name: handle_follow_counts
-- Type: Trigger Function (تعمل تلقائياً عند الإدراج أو الحذف في جدول follows)
-- Description:
-- وظيفتها تحديث عدادات المتابعين (followers_count) والمتابَعين (following_count) في جدول المستخدمين.
--
-- لماذا هذه الدالة مهمة؟
-- بدلاً من حساب العدد في كل مرة نفتح فيها البروفايل (عن طريق Count(*))، نقوم بتخزين الرقم جاهزاً في جدول المستخدم.
-- هذا الأسلوب يسمى "Denormalization" وهو أساسي للتطبيقات السريعة.
--
-- التحسينات الموجودة في الكود:
-- 1. Coalesce: عشان لو القيمة لسه NULL يعتبرها 0 ومايطلعش خطأ.
-- 2. Greatest(..., 0): عشان مستحيل العداد ينزل تحت الصفر (سالب) لو حصل أي خطأ في التزامن.
--
-- تقييم الأداء (Performance):
-- - بيخلي عرض البروفايل "صاروخي" 🚀 لأن الرقم جاهز ومش محتاج حساب.
-- - تكلفة الكتابة (Write Cost) بسيطة جداً (تحديث سطرين فقط عند كل فولو).
--
-- تقييم الباندويدث (Bandwidth):
-- - صفر (Zero). العملية كلها بتتم في السيرفر في الخلفية.

CREATE OR REPLACE FUNCTION public.handle_follow_counts()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if (TG_OP = 'INSERT') then
    -- User A follows User B
    -- User B gains a follower
    update public.users
    set followers_count = coalesce(followers_count, 0) + 1
    where id = new.following_id;
    -- User A gains a following
    update public.users
    set following_count = coalesce(following_count, 0) + 1
    where id = new.follower_id;
    
    return new;
  
  elsif (TG_OP = 'DELETE') then
    -- User A unfollows User B
    -- User B loses a follower
    update public.users
    set followers_count = greatest(coalesce(followers_count, 0) - 1, 0)
    where id = old.following_id;
    -- User A loses a following
    update public.users
    set following_count = greatest(coalesce(following_count, 0) - 1, 0)
    where id = old.follower_id;
    
    return old;
  end if;
  return null;
end;
$function$
