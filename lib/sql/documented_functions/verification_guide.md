# دليل اختبار دوال SUpabase الجديدة
قم بنسخ هذه الأوامر وتشغيلها في **Supabase SQL Editor** للتأكد من أن كل شيء يعمل بشكل صحيح.
يجب عليك استبدال `YOUR_USER_ID_HERE` و `TARGET_USER_ID_HERE` بمعرفات حقيقية من جدول `users`.

## 1. اختبار `get_full_profile` (البروفايل الشامل)
هذا الأمر يجب أن يعيد لك JSON يحتوي على بيانات المستخدم + الإحصائيات + حالة العلاقة (فولو/بلوك).

```sql
-- استبدل الـ UUIDs بمعرفات حقيقية
SELECT * FROM public.get_full_profile(
  'MY_UUID_HERE',      -- معرفك أنت (أو null للتجربة كزائر)
  'TARGET_UUID_HERE'   -- معرف الشخص اللي عايز تفتح بروفايله
);
```
**المتوقع:**
- التأكد من أن حقل `user` يحتوي على البيانات.
- التأكد من `stats.questions_count`.
- التأكد من `relationship.is_following` (جرب تعمل فولو/أنفولو وشوف النتيجة).

---

## 2. اختبار `check_user_availability` (فحص التسجيل)
جرب إدخال بيانات موجودة وبيانات جديدة لمشاهدة الفرق.

```sql
SELECT * FROM public.check_user_availability(
  '01012345678',       -- رقم هاتف (جرب رقم موجود ورقم جديد)
  'new_username',      -- اسم مستخدم
  'email@test.com',    -- بريد إلكتروني
  NULL                 -- اتركه NULL عند تسجيل مستخدم جديد
);
```
**المتوقع:**
- لو البيانات مستخدمة، سترى `true`.
- لو البيانات جديدة ومتاحة، سترى `false`.

---

## 3. اختبار `get_profile_questions` (أسئلة البروفايل)
هذا الأمر يجب أن يحضر الأسئلة مرتبة (المثبت أولاً).

```sql
SELECT id, title, is_pinned, is_liked, sender->>'name' as sender_name 
FROM public.get_profile_questions(
  'MY_UUID_HERE',      -- معرفك أنت (عشان يعرف انت عامل لايك ولا لأ)
  'TARGET_UUID_HERE',  -- البروفايل اللي بتعرضه
  10,                  -- عدد النتائج (Limit)
  0                    -- البداية (Offset)
);
```
**المتوقع:**
- ظهور الأسئلة التي `is_pinned = true` في البداية.
- ظهور `is_liked = true` للأسئلة التي أعجبتك.
- عدم ظهور أسئلة من أشخاص أنت قمت بحظرهم.

---

## 4. اختبار `get_inbox_questions` (صندوق الوارد)
هذا الأمر يجب أن يحضر الأسئلة الجديدة التي لم يتم الرد عليها فقط.

```sql
SELECT id, title, created_at, sender->>'name' as sender_name
FROM public.get_inbox_questions(
  'MY_UUID_HERE',      -- معرفك أنت (صاحب الصندوق)
  10,                  -- Limit
  0                    -- Offset
);
```
**المتوقع:**
- ظهور أسئلة موجهة لك ولكن `answered_at` الخاص بها `NULL`.
- عدم ظهور أي سؤال قمت بالرد عليه سابقاً.
