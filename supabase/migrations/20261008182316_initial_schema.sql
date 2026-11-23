-- Project 09 - Supabase Secure Build
-- Migration: initial_schema
--
-- A multi-tenant application backend (profiles -> accounts -> transactions).
-- Every row is owned by an authenticated user. Row-Level Security (RLS) is
-- enabled on every table, and NO policies are defined yet -- so with RLS on
-- and zero policies the Data API denies ALL rows to every client (anon and
-- authenticated). That is "secure by default": nothing is reachable until
-- explicit, least-privilege policies are added in the next stage (Test-04).

-- 1. profiles: exactly one public profile per authenticated user.
create table public.profiles (
    id          uuid        primary key references auth.users (id) on delete cascade,
    full_name   text        not null,
    created_at  timestamptz not null default now()
);
comment on table public.profiles is
    'One profile per auth user. Ownership key: profiles.id = auth.uid().';

-- 2. accounts: each account belongs to exactly one owner (an auth user).
create table public.accounts (
    id            uuid        primary key default gen_random_uuid(),
    owner_id      uuid        not null references auth.users (id) on delete cascade,
    account_name  text        not null,
    balance_cents bigint      not null default 0,
    created_at    timestamptz not null default now()
);
comment on table public.accounts is
    'Tenant-owned accounts. Isolation key: accounts.owner_id = auth.uid().';
create index accounts_owner_id_idx on public.accounts (owner_id);

-- 3. transactions: each transaction belongs to exactly one account.
create table public.transactions (
    id           uuid        primary key default gen_random_uuid(),
    account_id   uuid        not null references public.accounts (id) on delete cascade,
    amount_cents bigint      not null,
    description  text,
    created_at   timestamptz not null default now()
);
comment on table public.transactions is
    'Ledger entries. Reachable only through an account the caller owns.';
create index transactions_account_id_idx on public.transactions (account_id);

-- Secure by default: enable RLS explicitly on every table (do not rely only
-- on the project-level auto-RLS trigger -- the migration must be self-contained
-- and reproducible with `supabase db reset`). With RLS on and no policies,
-- the API returns nothing to clients until Test-04 grants least-privilege access.
alter table public.profiles     enable row level security;
alter table public.accounts     enable row level security;
alter table public.transactions enable row level security;
