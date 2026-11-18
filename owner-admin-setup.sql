-- AK3OR Digital Hub: promote exactly one Supabase account as site owner.
-- 1) Create your user in Supabase Dashboard > Authentication > Users.
-- 2) Copy that user's UUID.
-- 3) Replace the UUID below, then run this file in SQL Editor.
-- This removes admin rights from every other profile before promoting your account.

update public.profiles
set is_admin = false
where is_admin = true;

insert into public.profiles (id, is_admin)
values ('5ce486a2-73a1-40f0-a359-b20db275e7fe', true)
on conflict (id)
do update set is_admin = true;

-- Then disable public sign-ups in Supabase Authentication settings.
