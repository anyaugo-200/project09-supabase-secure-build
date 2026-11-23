-- Project 09 - Supabase Secure Build
-- Seed: synthetic data for the two test users (alice, bob).
--
-- This is the SAME SQL run once in the dashboard SQL Editor against the remote
-- project. It is kept here as code: Supabase runs `supabase/seed.sql` after the
-- migrations on a local `supabase db reset`, so the whole environment (schema +
-- RLS + seed) is reproducible from the repo.
--
-- It resolves the two users by email, so no UUIDs are hard-coded. If the test
-- users do not exist (e.g. a fresh local DB without Auth users), the lookups
-- return nothing and this seed is a safe no-op. Run once per environment.

insert into public.profiles (id, full_name)
select id, 'Alice Tester' from auth.users where email = 'alice@example.com'
on conflict (id) do nothing;

insert into public.profiles (id, full_name)
select id, 'Bob Tester' from auth.users where email = 'bob@example.com'
on conflict (id) do nothing;

with acct as (
  insert into public.accounts (owner_id, account_name, balance_cents)
  select id, 'Alice Current', 1500000 from auth.users where email = 'alice@example.com'
  returning id)
insert into public.transactions (account_id, amount_cents, description)
select id, -2500, 'Coffee' from acct
union all select id, 500000, 'Salary' from acct;

with acct as (
  insert into public.accounts (owner_id, account_name, balance_cents)
  select id, 'Bob Savings', 9900000 from auth.users where email = 'bob@example.com'
  returning id)
insert into public.transactions (account_id, amount_cents, description)
select id, -1000, 'Snack' from acct
union all select id, 750000, 'Bonus' from acct;
