DO $$
DECLARE
  v_user_ids UUID[];
  v_question_ids UUID[];
  v_user_record RECORD;
  v_temp_id UUID;
BEGIN
  RAISE NOTICE 'Starting seeding data...';

  -- 1. Insert 50 Users
  -- We use a loop or CTE. CTE is cleaner for bulk insert.
  WITH inserted_users AS (
    INSERT INTO public.users (
      id, 
      created_at, 
      name, 
      username, 
      email, 
      provider, 
      token, 
      -- upload removed as it does not exist in DB
      image, 
      app_version, 
      followers_count, 
      following_count, 
      bio, 
      posts_count, 
      can_asked_anonymously, 
      is_verified, 
      is_blocked, 
      phone
    )
    SELECT
      gen_random_uuid(),
      NOW(),
      'User ' || substring(md5(random()::text) from 1 for 4), -- Random suffix name
      'user_' || floor(extract(epoch from now())) || '_' || i, -- Ensure unique username
      'user_' || floor(extract(epoch from now())) || '_' || i || '@domandito.com', 
      'email',
      '',
      -- false removed (value for upload)
      'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png',
      '1.0.0',
      0, -- Will update later or let triggers handle if they exist
      0,
      'Bio for User ' || i || '. I love asking questions!',
      40, -- We will insert 40 questions
      true,
      false,
      false,
      '000000' || i
    FROM generate_series(1, 50) i
    RETURNING id
  )
  SELECT array_agg(id) INTO v_user_ids FROM inserted_users;

  IF v_user_ids IS NULL THEN
      RAISE EXCEPTION 'Failed to create users';
  END IF;

  RAISE NOTICE 'Created % users', array_length(v_user_ids, 1);

  -- 2. Insert Questions (50 users * 40 questions = 2000 questions)
  -- Logic: Each of the 50 users (as receivers) gets 40 questions from random senders
  WITH inserted_questions AS (
    INSERT INTO public.questions (
      id, created_at, answered_at, title, answer_text, 
      is_deleted, images, is_anonymous, likes_count, comments_count, is_pinned,
      sender_id, receiver_id
    )
    SELECT
      gen_random_uuid(),
      NOW() - (random() * interval '30 days'),
      NOW() - (random() * interval '29 days'), -- Answered shortly after
      'Question #' || q_idx || ' for this user. What do you think about AI?',
      'This is a generated answer for question #' || q_idx || '. It is great!',
      false,
      '{}', -- text[] for images
      (random() < 0.2), -- 20% anonymous
      50, -- Initialize with 50 likes count
      0,
      false,
      -- Sender: Select a random ID from v_user_ids that is NOT the receiver (u.id)
      (
        SELECT id 
        FROM unnest(v_user_ids) as id 
        WHERE id <> u.id 
        ORDER BY random() 
        LIMIT 1
      ),
      u.id -- Receiver is the user themselves
    FROM 
      (SELECT unnest(v_user_ids) as id) u,
      generate_series(1, 40) q_idx
    RETURNING id
  )
  SELECT array_agg(id) INTO v_question_ids FROM inserted_questions;

  RAISE NOTICE 'Created % questions', array_length(v_question_ids, 1);

  -- 3. Insert Likes (2000 questions * 50 likes = 100,000 likes)
  -- This creates 50 likes for EACH question from random users
  INSERT INTO public.likes (question_id, user_id, created_at)
  SELECT
    q.id,
    (v_user_ids)[1 + floor(random() * 50)::int], -- Random user index 1-50
    NOW()
  FROM
    (SELECT unnest(v_question_ids) as id) q,
    generate_series(1, 50) l_idx
  ON CONFLICT DO NOTHING; -- Skip if random user picked twice (unlikely to affect count much)

  RAISE NOTICE 'Created likes';

  -- 4. Follows (Each user follows 20 random others)
  INSERT INTO public.follows (created_at, follower_id, following_id)
  SELECT
    NOW(),
    u.id, -- Follower
    (v_user_ids)[1 + floor(random() * 50)::int] -- Following (Random)
  FROM
    (SELECT unnest(v_user_ids) as id) u,
    generate_series(1, 20) f_idx
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Seeding completed successfully.';

END $$;
