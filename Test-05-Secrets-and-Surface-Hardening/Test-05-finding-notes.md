# Test 05 — Secrets & Surface Hardening
### Project 09 — Supabase Secure Build · baseline security posture

## Control objective
Lock down the project's secrets and attack surface, and establish a baseline
security posture with an automated scan before the manual penetration test.

## Key hygiene
- **Two API keys, very different trust levels:**
  - `anon` (public) — safe in client/browser code; RLS protects the data behind it.
  - `service_role` (secret) — **bypasses RLS entirely** (full admin). Never commit,
    paste, or screenshot it. It was kept hidden in all evidence (Test-5A).
- Added a project **`.gitignore`** excluding `.env`, `*.key`, `*.pem`, and the
  Supabase CLI temp dirs, so no secret can reach the repo when published.
- (Note: Supabase also offers newer *publishable / secret* API keys; this build
  uses the legacy `anon` / `service_role` keys that the CLI and client use.)

## Baseline security scan — Supabase Security Advisor (splinter Postgres linter)
**Result: 0 errors, 3 warnings.** The three warnings resolve to two findings.

### Finding P09-F1 — Over-privileged SECURITY DEFINER function
| Field | Detail |
|---|---|
| Entity | `public.rls_auto_enable()` |
| Issue | Executable by both `anon` (public) and `authenticated` (signed-in) roles |
| Severity | **Low** (least-privilege / hardening) |
| Class | CWE-269 Improper Privilege Management |
| Evidence | Test-5B |

A `SECURITY DEFINER` function runs with the privileges of its **owner**, not the
caller. This function was created automatically by the **"automatic RLS"**
convenience setting enabled at provisioning. Leaving it executable by untrusted
roles violates least privilege and is an unnecessary privilege-escalation surface.
The function itself is benign (it only enables RLS), so the practical risk is low,
but the exposure is a real hardening gap — and a useful lesson that a convenience
feature introduced attack surface.

**Fix (Test-08):** `revoke execute on function public.rls_auto_enable() from anon, authenticated, public;`

### Finding P09-F2 — Leaked-password protection disabled
| Field | Detail |
|---|---|
| Entity | Auth |
| Issue | Leaked-password protection is disabled (default off) |
| Severity | **Medium** |
| Class | CWE-521 Weak Password Requirements |
| Evidence | Test-5B |

Supabase Auth can reject new passwords found in the HaveIBeenPwned breach corpus.
It is **off by default**, so users could set passwords already known to be
compromised — a credential-stuffing / account-takeover risk.

**Fix (Test-08):** Authentication → Sign In / Providers → Password security →
enable "Prevent use of leaked passwords."

## Status
Both findings **documented at baseline** here. Remediation and a re-scan proving
**0 warnings** are performed in Test-08 (fix-and-retest).

## Evidence files
- `Test-5A-supabase-api-keys-anon-vs-service-role.png`
- `Test-5B-supabase-security-advisor-warnings-baseline.png`
- `Test-5C-supabase-security-advisor-no-errors.png`

## Scope
All testing performed against infrastructure I own and control, in an isolated lab environment.
