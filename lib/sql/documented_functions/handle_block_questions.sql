-- Function Name: handle_block_questions
-- Type: Trigger Function (تعمل تلقائياً عند الإدراج في جدول blocks)
-- Description:
-- وظيفتها إدارة مصير الأسئلة بين شخصين عند حدوث "بلوك" أو "إلغاء بلوك".
--
-- المنطق (Logic) الذكي:
-- 1. عند عمل البلوك (INSERT):
--    - لا تقوم بمسح الأسئلة فعلياً (Hard Delete) لأننا قد نحتاجها عند فك البلوك.
--    - تقوم بإخفائها فقط (Soft Delete) عن طريق وضع علامة is_deleted = true.
--    - الأهم: تضع علامة إضافية اسمها deleted_by_block = true. دي زي "ختم" بنحطه عشان نعرف
--      إن السؤال ده اختفى "بسبب البلوك" مش عشان المستخدم هو اللي مسحه بإيده.
--
-- 2. عند فك البلوك (DELETE):
--    - تقوم باسترجاع الأسئلة المخفية، ولكن بشرط واحد مهم جداً:
--    - بترجع بس الأسئلة اللي عليها ختم deleted_by_block = true.
--    - ده بيضمن إننا منرجعش أسئلة كان المستخدم مسحها بنفسه قاصد.
--
-- تقييم الأداء (Performance):
-- - ممتاز. الـ Trigger بيشتغل مرة واحدة بس لحظة البلوك/فك البلوك.
-- - لا يؤثر على سرعة التصفح اليومي.
-- - بيعتمد على sender_id و receiver_id والمفروض يكون عليهم Index.
--
-- تقييم الباندويدث (Bandwidth):
-- - صفر (Zero). دي عملية بتتم بالكامل داخل الداتابيس (Server-Side).
-- - التطبيق مش بيبعت ولا بيستقبل أي بيانات عن الأسئلة دي، هو بيبعت بس أمر البلوك.

CREATE OR REPLACE FUNCTION public.handle_block_questions()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if (TG_OP = 'INSERT') then
    -- BLOCK ACTION
    -- Mark visible questions as deleted AND flag them as deleted_by_block
    update questions
    set 
      is_deleted = true,
      deleted_by_block = true
    where 
      is_deleted = false -- Only affect currently visible questions
      and is_anonymous = false -- 🛡️ SECURITY: Don't hide anonymous questions to protect sender identity
      and (
        (sender_id = NEW.blocker_id and receiver_id = NEW.blocked_id)
        or
        (sender_id = NEW.blocked_id and receiver_id = NEW.blocker_id)
      );
    return NEW;
    
  elsif (TG_OP = 'DELETE') then
    -- UNBLOCK ACTION
    -- Restore ONLY questions that were deleted by a block
    update questions
    set 
      is_deleted = false,
      deleted_by_block = false
    where 
      deleted_by_block = true -- Safety check: restore only what we hid
      and is_anonymous = false -- Safety check: consistent with block logic
      and (
        (sender_id = OLD.blocker_id and receiver_id = OLD.blocked_id)
        or
        (sender_id = OLD.blocked_id and receiver_id = OLD.blocker_id)
      );
    return OLD;
  end if;
  return null;
end;
$function$
