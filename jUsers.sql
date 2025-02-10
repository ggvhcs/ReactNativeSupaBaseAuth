-- 1- Create a table for public _jusers
DROP TABLE IF EXISTS _jusers cascade;
create table _jusers (
  _jusersid  varchar(16)     not null unique,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  username   varchar(8)     not null unique,
  phone      varchar(16)     not null unique,
  email      varchar(50)     not null,
  PRIMARY KEY(_jusersid),
  constraint phone check (char_length(username) >= 8)
);

-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.

alter table _jusers enable row level security;

create policy "Public _jusers are viewable by everyone." on _jusers for select using (true);

--create policy "Public _jusers are viewable by everyone." on _jusers for insert using (true);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create function public.handle_new_user()
returns trigger
set search_path = ''
as $$
begin
  insert into public._jusers (id, phone)
  values (new.id, new.raw_user_meta_data->>'phone');
  return new;
end;
--$$ language plpgsql security definer;
--create trigger on_auth_user_created
--  after insert on auth._jusers
--  for each row execute procedure public.handle_new_user();

-- Set up Storage!
--insert into storage.buckets (id, name)
--  values ('avatars', 'avatars');

-- Set up access controls for storage.
-- See https://supabase.com/docs/guides/storage#policy-examples for more details.
--create policy "Avatar images are publicly accessible." on storage.objects
--  for select using (bucket_id = 'avatars');

--create policy "Anyone can upload an avatar." on storage.objects
--  for insert with check (bucket_id = 'avatars');                
