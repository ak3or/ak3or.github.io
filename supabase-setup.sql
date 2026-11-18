-- AK3OR Digital Hub — Supabase setup
-- Run this entire file in Supabase Dashboard > SQL Editor.
-- The frontend must use ONLY the project's public anon/publishable key.
-- Never put a service_role key in index.html.

create extension if not exists pgcrypto;

-- 1) Owner profiles. New accounts are NOT admins by default.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, is_admin)
  values (new.id, false)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Security-definer helper avoids recursive profile RLS checks.
create or replace function public.is_site_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  );
$$;
revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to anon, authenticated;

-- 2) Content tables.
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'General',
  description text not null default '',
  content text not null default '',
  cover_url text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category text not null default 'Files',
  file_type text not null default 'FILE',
  file_size text not null default '',
  download_url text not null,
  storage_path text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  version text,
  platform text not null,
  category text not null default 'Applications',
  description text not null default '',
  icon_url text,
  download_url text not null,
  storage_path text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.social_links (
  id uuid primary key default gen_random_uuid(),
  platform text not null,
  url text not null,
  visible boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- Seed the owner's supplied social profiles. Safe to re-run: update matching platform rows, then insert missing ones.
with seed(platform, url, sort_order) as (
  values
    ('Instagram', 'https://www.instagram.com/or7ka/', 10),
    ('TikTok', 'https://www.tiktok.com/@ak3or', 20),
    ('YouTube', 'https://www.youtube.com/@ak3or', 30),
    ('GitHub', 'https://github.com/ak3or', 40),
    ('Discord', 'https://discord.gg/naHB2YVwKR', 50)
)
update public.social_links existing
set url = seed.url, visible = true, sort_order = seed.sort_order
from seed
where lower(existing.platform) = lower(seed.platform);

insert into public.social_links (platform, url, visible, sort_order)
select seed.platform, seed.url, true, seed.sort_order
from (values
  ('Instagram', 'https://www.instagram.com/or7ka/', 10),
  ('TikTok', 'https://www.tiktok.com/@ak3or', 20),
  ('YouTube', 'https://www.youtube.com/@ak3or', 30),
  ('GitHub', 'https://github.com/ak3or', 40),
  ('Discord', 'https://discord.gg/naHB2YVwKR', 50)
) as seed(platform, url, sort_order)
where not exists (
  select 1 from public.social_links existing
  where lower(existing.platform) = lower(seed.platform)
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  kind text not null default 'general',
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists posts_published_created_idx on public.posts (published, created_at desc);
create index if not exists files_published_created_idx on public.files (published, created_at desc);
create index if not exists apps_published_created_idx on public.applications (published, created_at desc);
create index if not exists social_visible_sort_idx on public.social_links (visible, sort_order);

-- 3) Enable Row Level Security everywhere.
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.files enable row level security;
alter table public.applications enable row level security;
alter table public.social_links enable row level security;
alter table public.categories enable row level security;
alter table public.site_settings enable row level security;

-- Remove policies from earlier runs so this script can be safely re-run.
drop policy if exists "profile owner can read own profile" on public.profiles;
drop policy if exists "public can read published posts" on public.posts;
drop policy if exists "admins manage posts" on public.posts;
drop policy if exists "public can read published files" on public.files;
drop policy if exists "admins manage files" on public.files;
drop policy if exists "public can read published apps" on public.applications;
drop policy if exists "admins manage apps" on public.applications;
drop policy if exists "public can read visible social links" on public.social_links;
drop policy if exists "admins manage social links" on public.social_links;
drop policy if exists "public can read categories" on public.categories;
drop policy if exists "admins manage categories" on public.categories;
drop policy if exists "public can read site settings" on public.site_settings;
drop policy if exists "admins manage site settings" on public.site_settings;

-- A user can read their own profile only. No client-side role promotion policy exists.
create policy "profile owner can read own profile"
on public.profiles for select to authenticated
using (id = (select auth.uid()));

create policy "public can read published posts"
on public.posts for select to anon, authenticated
using (published = true);
create policy "admins manage posts"
on public.posts for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

create policy "public can read published files"
on public.files for select to anon, authenticated
using (published = true);
create policy "admins manage files"
on public.files for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

create policy "public can read published apps"
on public.applications for select to anon, authenticated
using (published = true);
create policy "admins manage apps"
on public.applications for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

create policy "public can read visible social links"
on public.social_links for select to anon, authenticated
using (visible = true);
create policy "admins manage social links"
on public.social_links for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

create policy "public can read categories"
on public.categories for select to anon, authenticated
using (true);
create policy "admins manage categories"
on public.categories for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

create policy "public can read site settings"
on public.site_settings for select to anon, authenticated
using (key in ('public_title', 'public_description', 'default_theme'));
create policy "admins manage site settings"
on public.site_settings for all to authenticated
using ((select public.is_site_admin()))
with check ((select public.is_site_admin()));

-- Grant API access; Row Level Security still decides which rows/actions are allowed.
grant usage on schema public to anon, authenticated;
grant select on public.posts, public.files, public.applications, public.social_links, public.categories, public.site_settings to anon, authenticated;
grant select on public.profiles to authenticated;
grant insert, update, delete on public.posts, public.files, public.applications, public.social_links, public.categories, public.site_settings to authenticated;

-- 4) Create a public download bucket. Public read means anyone with a file URL can download it.
insert into storage.buckets (id, name, public, file_size_limit)
values ('public-files', 'public-files', true, 524288000)
on conflict (id) do update set public = true;

-- Public download access to the bucket. Uploads and file management remain owner-only.
drop policy if exists "public can download hub files" on storage.objects;
drop policy if exists "admins can upload hub files" on storage.objects;
drop policy if exists "admins can update hub files" on storage.objects;
drop policy if exists "admins can delete hub files" on storage.objects;
create policy "public can download hub files"
on storage.objects for select to anon, authenticated
using (bucket_id = 'public-files');
create policy "admins can upload hub files"
on storage.objects for insert to authenticated
with check (bucket_id = 'public-files' and (select public.is_site_admin()));
create policy "admins can update hub files"
on storage.objects for update to authenticated
using (bucket_id = 'public-files' and (select public.is_site_admin()))
with check (bucket_id = 'public-files' and (select public.is_site_admin()));
create policy "admins can delete hub files"
on storage.objects for delete to authenticated
using (bucket_id = 'public-files' and (select public.is_site_admin()));

-- 5) IMPORTANT: after creating your owner account in Supabase Authentication,
-- find its UUID in Authentication > Users, then run:
-- update public.profiles set is_admin = true where id = 'PASTE-OWNER-USER-UUID-HERE';
-- Do not add an admin-creation form to the public website.
