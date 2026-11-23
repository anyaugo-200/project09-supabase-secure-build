-- Project 09 - Supabase Secure Build
-- Migration: fix_revoke_rls_auto_enable_execute
--
-- Remediation for finding P09-F1 (Test-05 Security Advisor):
-- the SECURITY DEFINER function public.rls_auto_enable() -- created by the
-- "automatic RLS" convenience setting -- was EXECUTABLE by the anon and
-- authenticated roles. SECURITY DEFINER functions run with the owner's
-- privileges, so untrusted roles must not be able to call them (least privilege).
--
-- Fix: revoke EXECUTE from PUBLIC (and explicitly from anon / authenticated).
-- The function is still invoked automatically by its event trigger, which runs
-- as the table owner -- that path is unaffected.

revoke execute on function public.rls_auto_enable() from public;
revoke execute on function public.rls_auto_enable() from anon;
revoke execute on function public.rls_auto_enable() from authenticated;
