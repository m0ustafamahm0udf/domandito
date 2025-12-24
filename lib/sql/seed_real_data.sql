DO $$
DECLARE
  v_new_user_ids UUID[];
  v_question_ids UUID[];
  
  -- Arrays for Names
  v_first_names text[] := ARRAY[
    'أحمد', 'محمد', 'محمود', 'علي', 'عمر', 'يوسف', 'إبراهيم', 'حسن', 'خالد', 'طارق', 'كريم', 'مصطفى', 'عبدالرحمن', 'مازن', 'ياسين',
    'سارة', 'نور', 'مريم', 'سلمى', 'آية', 'فاطمة', 'هاجر', 'إسراء', 'منى', 'دينا', 'يارا', 'هند', 'ندى', 'نورهان', 'رنا'
  ];
  v_last_names text[] := ARRAY[
    'محمد', 'أحمد', 'محمود', 'علي', 'حسن', 'إبراهيم', 'السيد', 'عبدالله', 'عثمان', 'سالم', 'يوسف', 'كمال', 'صلاح', 'فوزي'
  ];

  -- Arrays for Q&A Content
  v_questions text[] := ARRAY[
    'ايه اكتر مكان بتحب تروحه؟',
    'اغنيتك المفضلة ايه؟',
    'بتعمل ايه في وقت فراغك؟',
    'صورة ليك وانت صغير؟',
    'اخر كتاب قرأته؟',
    'مواصفات شريك حياتك؟',
    'نصيحة لنفسك في الماضي؟',
    'ايه اكتر اكلة بتحبها؟',
    'مين اكتر حد أثر في حياتك؟',
    'حلمك ايه في المستقبل؟',
    'لو معاك مليون جنيه هتعمل بيهم ايه؟',
    'اكثر صفة بتحبها فيك؟',
    'اكثر صفة بتكرهها فيك؟',
    'بتحب الشتا ولا الصيف؟',
    'قهوة ولا شاي؟',
    'فيلمك المفضل؟',
    'اغنية معلقة معاك الفترة دي؟',
    'مكان نفسك تسافر له؟',
    'ايه رأيك في الحب من اول نظرة؟',
    'هل تؤمن بالابراج؟'
  ];
  
  v_answers text[] := ARRAY[
    'البحر اكيد',
    'عمرو دياب - تملي معاك',
    'بقرأ او بتفرج على افلام',
    'كنت شبه البطاطس 😂',
    'مبقرأش كتير للاسف',
    'يكون طيب وحنين',
    'متزعلش على اللي فات',
    'المكرونة البشاميل',
    'والدي الله يرحمه',
    'اني اسافر واللف العالم',
    'هتبرع بجزء واعمل مشروع',
    'الطيبة',
    'العصبية الزيادة',
    'الشتا طبعا 🌧️',
    'قهوة ☕',
    'Interstellar',
    'ويجز - البخت',
    'المالديف',
    'ممكن يحصل ليه لا',
    'لا خالص كلام فاضي'
  ];

BEGIN
  RAISE NOTICE 'Starting realistic seeding data...';

  -- 1. Insert 100 Users with Realistic Names
  WITH inserted_users AS (
    INSERT INTO public.users (
      id, created_at, name, username, email, provider, token, 
      image, app_version, followers_count, following_count, bio, 
      posts_count, can_asked_anonymously, is_verified, is_blocked, phone
    )
    SELECT
      gen_random_uuid(),
      NOW(),
      -- Random Name: FirstName + LastName
      (v_first_names)[1 + floor(random() * array_length(v_first_names, 1))::int] || ' ' || (v_last_names)[1 + floor(random() * array_length(v_last_names, 1))::int],
      
      -- Username: User + Timestamp + Index
      'user_' || floor(extract(epoch from now())) || '_' || i,
      
      -- Email
      'real_user_' || floor(extract(epoch from now())) || '_' || i || '@domandito.com', 
      
      'email', '',
      'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png',
      '1.0.0', 0, 0,
      'أحب الأسئلة والتواصل الاجتماعي', -- Arabic Bio
      40, true, false, false,
      '100000' || i -- Distinct phone prefix
    FROM generate_series(1, 100) i
    RETURNING id
  )
  SELECT array_agg(id) INTO v_new_user_ids FROM inserted_users;

  RAISE NOTICE 'Created % realistic users', array_length(v_new_user_ids, 1);

  -- 2. Insert Questions (100 users * 20 questions each to be realistic but dense)
  -- Each user receives questions from OTHER new users
  WITH inserted_questions AS (
    INSERT INTO public.questions (
      id, created_at, answered_at, title, answer_text, 
      is_deleted, images, is_anonymous, likes_count, comments_count, is_pinned,
      sender_id, receiver_id
    )
    SELECT
      gen_random_uuid(),
      NOW() - (random() * interval '30 days'),
      NOW() - (random() * interval '29 days'),
      
      -- Random Question from Array
      (v_questions)[1 + floor(random() * array_length(v_questions, 1))::int],
      
      -- Random Answer from Array
      (v_answers)[1 + floor(random() * array_length(v_answers, 1))::int],
      
      false, '{}', (random() < 0.2), 
      50 + floor(random() * 50)::int, -- Likes between 50 and 100
      0, false,
      
      -- Random Sender from the NEW users (excluding self)
      (
        SELECT id 
        FROM unnest(v_new_user_ids) as id 
        WHERE id <> u.id 
        ORDER BY random() 
        LIMIT 1
      ),
      u.id -- Receiver (The new user)
    FROM 
      (SELECT unnest(v_new_user_ids) as id) u,
      generate_series(1, 30) q_idx -- 30 Questions per user
    RETURNING id
  )
  SELECT array_agg(id) INTO v_question_ids FROM inserted_questions;

  RAISE NOTICE 'Created % questions', array_length(v_question_ids, 1);

  -- 3. Insert Likes (Dense likes: each question gets ~50 likes from random new users)
  INSERT INTO public.likes (question_id, user_id, created_at)
  SELECT
    q.id,
    (v_new_user_ids)[1 + floor(random() * array_length(v_new_user_ids, 1))::int],
    NOW()
  FROM
    (SELECT unnest(v_question_ids) as id) q,
    generate_series(1, 50) l_idx
  ON CONFLICT DO NOTHING;

  -- 4. Follows (Each new user follows ~25 others)
  INSERT INTO public.follows (created_at, follower_id, following_id)
  SELECT
    NOW(), u.id, (v_new_user_ids)[1 + floor(random() * array_length(v_new_user_ids, 1))::int]
  FROM
    (SELECT unnest(v_new_user_ids) as id) u,
    generate_series(1, 25) f_idx
  WHERE (v_new_user_ids)[1 + floor(random() * array_length(v_new_user_ids, 1))::int] <> u.id -- Simple check, conflict handles rest
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Realistic seeding completed.';

END $$;
