# Test 08 — Fix & Retest (remediation)
### Project 09 — Supabase Secure Build · the professional close: find → fix → prove

## Objective
Remediate the two findings from the Test-05 baseline scan and prove the fixes by
re-running the Security Advisor — stating any residual honestly.

## P09-F1 — Over-privileged SECURITY DEFINER function — **FIXED**
- **Fix (as code):** migration `20261009061941_fix_revoke_rls_auto_enable_execute.sql`
  revokes `EXECUTE` on `public.rls_auto_enable()` from `public`, `anon`, and `authenticated`.
  The function is still invoked by its event trigger (runs as the owner), so behaviour is unaffected.
- **Proven two ways:**
  1. **SQL check** (`verify_remediation_posture`, Test-8C): `has_function_privilege` for
     `anon` and `authenticated` both return **false**; `anon` still cannot read the tables
     (false), `authenticated` still can (true) — the exposure is unchanged.
  2. **Security Advisor re-scan** (Test-8D): the two SECURITY DEFINER warnings are **gone**.
- **Status: remediated and proven.**

## P09-F2 — Leaked-password protection disabled — **PARTIALLY ADDRESSED (plan-gated)**
**Honest limitation:** Supabase gates leaked-password protection (the HaveIBeenPwned
Pwned Passwords API) behind **Pro plan and above**. It **cannot be enabled on the
free tier** used for this lab, so the Advisor **still flags it** after remediation.

- **Compensating controls applied on the free tier** (Auth → Email):
  - Minimum password length raised **6 → 12**.
  - Password requirements set to **lowercase + uppercase + digits + symbols**.
  - **Require current password when updating** enabled.
  - **Secure password change / secure email change** enabled.
- **Residual risk (documented):** without the HaveIBeenPwned check, a user could still
  pick a password that is strong-by-composition yet known-breached.
- **Production recommendation:** upgrade to **Pro** and enable leaked-password protection
  (a single toggle) to close this finding fully.
- **Status: compensating controls applied; ideal fix gated by plan; residual flagged.**

## Before / after — Security Advisor
| | Errors | Warnings |
|---|---|---|
| **Before** (Test-05 baseline, Test-5B) | 0 | **3** |
| **After** (Test-08 re-scan, Test-8D) | 0 | **1** (the plan-gated leaked-password item) |

**Net: 3 → 1.** Everything that could be fixed on the free tier is fixed and proven;
the one item that could not is documented honestly, with compensating controls and a
clear production path. No result is overstated.

## Evidence files
- `Test-8A-supabase-db-push-fix-applied.png` — P09-F1 migration pushed
- `Test-8B-supabase-password-policy-hardened.png` — free-tier password policy (min 12, strong requirements)
- `Test-8C-supabase-verify-remediation-sql.png` — SQL proof: P09-F1 revoked + exposure intact
- `Test-8D-2-supabase-security-advisor-after-fixes.png` — re-scan: 1 warning (the residual)
- `Test-8D-1-supabase-security-advisor-zero-errors.png` — re-scan: 0 errors

## Scope
All testing performed against infrastructure I own and control, in an isolated lab environment.
