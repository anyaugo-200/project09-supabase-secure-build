-- Project 09 - Supabase Secure Build
-- Migration: rls_policies
--
-- Least-privilege Row-Level Security. Each AUTHENTICATED user may read and
-- write ONLY their own rows. Policies target the `authenticated` role only,
-- so the `anon` (anonymous) role matches no policy and still sees nothing.
-- This is the correct tenant-isolation control -- the fix, done right, for
-- the cross-customer data access found in Project 08 (P08-F3).

-- ---------- profiles: owner is the row whose id = the caller's uid ----------
create policy "profiles_select_own" on public.profiles
    for select to authenticated
    using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
    for insert to authenticated
    with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
    for update to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);

-- ---------- accounts: owner_id must equal the caller's uid ----------
create policy "accounts_select_own" on public.accounts
    for select to authenticated
    using (auth.uid() = owner_id);

create policy "accounts_insert_own" on public.accounts
    for insert to authenticated
    with check (auth.uid() = owner_id);

create policy "accounts_update_own" on public.accounts
    for update to authenticated
    using (auth.uid() = owner_id)
    with check (auth.uid() = owner_id);

create policy "accounts_delete_own" on public.accounts
    for delete to authenticated
    using (auth.uid() = owner_id);

-- ---------- transactions: reachable only via an account the caller owns ----------
create policy "transactions_select_own" on public.transactions
    for select to authenticated
    using (exists (
        select 1 from public.accounts a
        where a.id = transactions.account_id
          and a.owner_id = auth.uid()));

create policy "transactions_insert_own" on public.transactions
    for insert to authenticated
    with check (exists (
        select 1 from public.accounts a
        where a.id = transactions.account_id
          and a.owner_id = auth.uid()));

create policy "transactions_update_own" on public.transactions
    for update to authenticated
    using (exists (
        select 1 from public.accounts a
        where a.id = transactions.account_id
          and a.owner_id = auth.uid()))
    with check (exists (
        select 1 from public.accounts a
        where a.id = transactions.account_id
          and a.owner_id = auth.uid()));

create policy "transactions_delete_own" on public.transactions
    for delete to authenticated
    using (exists (
        select 1 from public.accounts a
        where a.id = transactions.account_id
          and a.owner_id = auth.uid()));
