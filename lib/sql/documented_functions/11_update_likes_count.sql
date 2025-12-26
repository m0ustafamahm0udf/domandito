-- Function Name: update_likes_count
-- Type: Trigger Function (تعمل تلقائياً عند الإدراج أو الحذف في جدول likes)
-- Description:
-- وظيفتها تحديث عداد اللايكات (likes_count) في جدول الأسئلة.
--
-- الفكرة (Denormalization):
-- بدلاً من أن نقوم بعمل Count(*) لعدد اللايكات لكل سؤال في كل مرة نعرض فيها الصفحة (وهذا كارثي للأداء)،
-- نقوم بتخزين الرقم جاهزاً في جدول الأسئلة، وهذه الدالة مسؤولة عن تحديثه.
--
-- المنطق (Logic):
-- عند إضافة لايك (INSERT) -> تزيد العداد +1.
-- عند إزالة لايك (DELETE) -> تنقص العداد -1.
--
-- تقييم الأداء (Performance):
-- - يجعل تصفح الأسئلة سريعاً جداً لأن عدد اللايكات جاهز للقراءة فوراً.
-- - تكلفة الكتابة: تحديث بسيط لسطر واحد في جدول الأسئلة عند كل لايك.
--
-- تقييم الباندويدث (Bandwidth):
-- - صفر. العملية تتم في الخلفية.

CREATE OR REPLACE FUNCTION public.update_likes_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if (TG_OP = 'INSERT') then
    update questions
    set likes_count = likes_count + 1
    where id = NEW.question_id::uuid; -- Casting to UUID
    return NEW;
  elsif (TG_OP = 'DELETE') then
    update questions
    set likes_count = likes_count - 1
    where id = OLD.question_id::uuid; -- Casting to UUID
    return OLD;
  end if;
  return null;
end;
$function$
