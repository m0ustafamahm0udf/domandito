-- Fix RLS policies for notifications table

-- Drop existing policies to ensure a clean slate
drop policy if exists "Users can view their own notifications" on public.notifications;
drop policy if exists "Users can update their own notifications (mark as read)" on public.notifications;
drop policy if exists "Users can insert notifications" on public.notifications;
drop policy if exists "Enable insert for authenticated users only" on public.notifications;

-- Re-create policies

-- 1. SELECT: Users can only see notifications sent TO them
create policy "Users can view their own notifications"
on public.notifications for select
to authenticated
using (auth.uid() = user_id);

-- 2. UPDATE: Users can only update notifications sent TO them (e.g. mark as read)
create policy "Users can update their own notifications (mark as read)"
on public.notifications for update
to authenticated
using (auth.uid() = user_id);

-- 3. INSERT: Authenticated users can insert notifications for ANYONE
-- (This is necessary because User A needs to insert a notification for User B)
create policy "Users can insert notifications"
on public.notifications for insert
to authenticated
with check (true);
