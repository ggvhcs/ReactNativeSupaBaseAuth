-- Create a table for public profiles
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  picture_profile text,
  website text,

  constraint username_length check (char_length(username) >= 6)
);
-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles for select using (true);

create policy "Users can insert their own profile." on profiles for insert with check ((select auth.uid()) = id);

create policy "Users can update own profile." on profiles for update using ((select auth.uid()) = id);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create function public.handle_new_user()
returns trigger
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, picture_profile)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'picture_profile');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Set up Storage!
insert into storage.buckets (id, name) values ('picture_profile', 'picture_profile');

-- Set up access controls for storage.
-- See https://supabase.com/docs/guides/storage#policy-examples for more details.
create policy "picture_profile images are publicly accessible." on storage.objects for select using (bucket_id = 'picture_profile');

create policy "Anyone can upload an picture_profile." on storage.objects for insert with check (bucket_id = 'picture_profile');