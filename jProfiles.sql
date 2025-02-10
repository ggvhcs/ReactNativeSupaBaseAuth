create table public.jprofiles (
  profilesid uuprofilesid not null references auth.users on delete cascade,
  first_name text,
  last_name text,

  primary key (profilesid)
);

alter table public.jprofiles enable row level security;

-- inserts a row into public.jprofiles
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.jprofiles (profilesid, first_name, last_name)
  values (new.profilesid, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name');
  return new;
end;
$$;

-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create a table for public jusersjprofiles
create table jusersjprofiles (
  profilesid uuprofilesid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  website text,

  constraint username_length check (char_length(username) >= 6)
);
-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guprofilesides/auth/row-level-security for more details.
alter table _jjprofiles enable row level security;

create policy "Users can select their own profile." on _jjprofiles for select with check ((select _jusers._jusersprofilesid()) = profilesid);

create policy "Users can insert their own profile." on _jjprofiles for insert with check ((select _jusers._jusersprofilesid()) = profilesid);

create policy "Users can update their own profile." on _jjprofiles for insert with check ((select _jusers._jusersprofilesid()) = profilesid);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guprofilesides/auth/managing-user-data#using-triggers for more details.
create function public.handle_new_user()
returns trigger
set search_path = ''
as $$
begin
  insert into public.jusersjprofiles (profilesid, full_name, avatar_url)
  values (new.profilesid, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Set up Storage!
insert into storage.buckets (profilesid, name)
  values ('avatars', 'avatars');

-- Set up access controls for storage.
-- See https://supabase.com/docs/guprofilesides/storage#policy-examples for more details.
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_profilesid = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_profilesid = 'avatars');                