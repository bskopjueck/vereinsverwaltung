-- ============================================================
-- BSK Op Jück Vereinsverwaltung – Supabase-Einrichtung
-- Einmal im Supabase SQL-Editor ausführen (Dashboard → SQL Editor
-- → New query → alles einfügen → Run).
-- ============================================================

-- Benutzerprofile (wird bei Registrierung automatisch befüllt)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  name text,
  role text not null default 'vorstand',       -- 'admin' oder 'vorstand'
  approved boolean not null default false,     -- Freischaltung durch Admin
  created_at timestamptz default now()
);

-- Gemeinsamer Datenstand des Vereins (eine Zeile)
create table if not exists public.app_state (
  id int primary key check (id = 1),
  data jsonb not null,
  version bigint not null default 1,
  updated_by text,
  updated_at timestamptz default now()
);

-- Profil automatisch anlegen, wenn sich jemand registriert
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name',''));
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Hilfsfunktionen für die Zugriffsregeln
create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public as
$$ select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin' and approved) $$;

create or replace function public.is_approved()
returns boolean language sql security definer set search_path = public as
$$ select exists(select 1 from public.profiles where id = auth.uid() and approved) $$;

-- Zugriffsregeln (Row Level Security)
alter table public.profiles  enable row level security;
alter table public.app_state enable row level security;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
  for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists state_select on public.app_state;
create policy state_select on public.app_state
  for select to authenticated using (public.is_approved());

drop policy if exists state_insert on public.app_state;
create policy state_insert on public.app_state
  for insert to authenticated with check (public.is_approved());

drop policy if exists state_update on public.app_state;
create policy state_update on public.app_state
  for update to authenticated
  using (public.is_approved()) with check (public.is_approved());

-- ============================================================
-- WICHTIG – DICH SELBST ZUM ADMIN MACHEN:
-- 1. Erst in der App registrieren (Konto erstellen).
-- 2. Dann die Zeile unten mit DEINER E-Mail ausführen:
-- ============================================================
-- update public.profiles set role = 'admin', approved = true where email = 'DEINE@MAIL.DE';
