-- Create the notifications table
create table public.notifications (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  user_id uuid not null references public.users (id) on delete cascade,
  sender_id uuid references public.users (id) on delete set null,
  type text not null check (type in ('like', 'answer', 'question', 'follow')),
  entity_id text, -- ID of the question or answer
  title text,
  body text,
  is_read boolean not null default false,
  constraint notifications_pkey primary key (id)
);

-- Enable Row Level Security
alter table public.notifications enable row level security;

-- Policies
create policy "Users can view their own notifications"
on public.notifications for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can update their own notifications (mark as read)"
on public.notifications for update
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert notifications"
on public.notifications for insert
to authenticated
with check (true);
