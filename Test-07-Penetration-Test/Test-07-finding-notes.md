# Test 07 — Penetration Test (RLS tenant isolation)
### Project 09 — Supabase Secure Build · OWASP API1:2023 Broken Object Level Authorization

## Control objective
Prove, over the **live Data API**, that per-user tenant isolation (RLS) actually
holds — that the cross-customer data access which was the finding in Project 08
(**P08-F3**) is impossible here. Attacker positions: (a) an external client with
only the **public anon key**, and (b) a **logged-in user** trying to reach
another user's data.

## Attacker model
External client over the internet to the project's PostgREST Data API
(`/rest/v1/...`) and Auth API (`/auth/v1/token`), holding the public anon key and
two synthetic test accounts (alice, bob, password-authenticated). No service_role,
no admin access. Script: `pentest-rls-isolation.sh`; raw output: `Test-07-pentest-output.txt`.

**Credential-handling note (good practice):** test-account passwords were entered
at runtime via a **masked prompt** (`Read-Host -AsSecureString`, converted, used,
then zeroed from memory) — never hard-coded in a command, screenshot, or shell
history. The reproducible script takes secrets from environment variables for the
same reason. Only the *public* anon key is ever shown.

## Results — the isolation HOLDS
| # | Attack | Result | Verdict |
|---|---|---|---|
| A | Anonymous (anon key only) reads `accounts` | **HTTP 401** `permission denied for table accounts` | **BLOCKED** |
| B | Alice (authenticated) reads `accounts` | returns **only** "Alice Current" | correct |
| C | Alice reads `transactions` | returns **only** hers (Coffee, Salary) | correct |
| D | Alice explicitly filters for **Bob's** `owner_id` | returns **`[]`** (empty) | **BLOCKED** |
| E | Bob reads `accounts` | returns **only** "Bob Savings" | correct |

**Test D is the key result.** Alice, logged in, explicitly requested Bob's account
by his user id — the exact Project-08 cross-customer attack — and the API returned
an empty list. RLS filters every query to the caller's own rows, and the `anon`
role has no table grant at all. **The secure build works; P08-F3 is fixed, done right.**

## Mapping
OWASP API Security Top 10 — **API1:2023 Broken Object Level Authorization (BOLA)**:
**tested and NOT vulnerable.** RLS enforces object-level authorization in the
database itself, so it cannot be bypassed from the client.

## Detection (ties to Test-06)
The anonymous attack (Test A) is recorded as an **HTTP 401 / 4xx** in the Supabase
API / PostgREST logs — the monitoring layer sees the denied request, closing the
watch → attack → see-it loop. Evidence: `Test-7G-supabase-logs-4xx-anon-denied.png`.

## Outcome (honest)
This is a **PASS**: no anonymous access, no cross-tenant access. The core security
claim of the build is validated. The build is **not vulnerability-free**, though —
the two real findings on it (**P09-F1** over-privileged SECURITY DEFINER function,
**P09-F2** leaked-password protection disabled) were surfaced by the Security
Advisor in Test-05 and are remediated in Test-08.

## Evidence files (terminal, step-by-step)
- `Test-7A-anon-read-accounts-blocked.png` — anonymous read denied (permission denied / 401)
- `Test-7B-alice-login-token-acquired.png` — Alice authenticates
- `Test-7C-alice-reads-own-account.png` — Alice sees only her account
- `Test-7D-alice-reads-own-transactions.png` — Alice sees only her transactions
- `Test-7E-alice-attacks-bob-blocked-zero-rows.png` — Alice gets **0 rows** of Bob's data (the key result)
- `Test-7F-bob-reads-own-account.png` — Bob sees only his account
- `Test-7G-supabase-logs-4xx-anon-denied.png` — detection: the anon attack as a 4xx in the logs
- `pentest-rls-isolation.sh`, `Test-07-pentest-output.txt` — reproducible script + raw results

## Scope
All testing performed against infrastructure I own and control, in an isolated lab environment.
