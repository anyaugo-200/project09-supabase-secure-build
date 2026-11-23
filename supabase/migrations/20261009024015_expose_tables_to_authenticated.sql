-- Project 09 - Supabase Secure Build
-- Migration: expose_tables_to_authenticated
--
-- "Automatically expose new tables" was left OFF at project creation (secure by
-- default), so the three tables are not reachable through the Data API yet.
-- Here we make the exposure a DELIBERATE, reviewed decision: grant table
-- privileges to the `authenticated` role ONLY. The `anon` role is intentionally
-- never granted, so anonymous callers cannot touch these tables at all.
--
-- Row-Level Security (already enabled, with per-owner policies) is what then
-- restricts each authenticated user to their own rows. Exposure + RLS together
-- is the standard, safe Supabase pattern: the API is open to logged-in users,
-- but every query is still filtered to the caller's own data.

grant select, insert, update, delete on public.profiles     to authenticated;
grant select, insert, update, delete on public.accounts     to authenticated;
grant select, insert, update, delete on public.transactions to authenticated;

-- anon is deliberately NOT granted. (No `grant ... to anon;` lines.)
