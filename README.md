# Project 9 — Supabase Secure Build

### Anyaugo Space-Tech Ltd. · Security Training | Lab Evidence

**A hands-on secure-cloud case study: design, deploy, and harden a realistic multi-tenant backend on Supabase the way a company would — then attack it from a customer's position, fix what the attack and the config audit find, and prove the business can recover its data from an isolated backup after a fatal breach without paying a ransom.** The engagement is run as both roles a company pays for: the **cloud architect** (the design, before the build) and the **cloud security engineer** (deploy, harden, monitor, pentest, remediate, recover). All work was done on infrastructure the agency owns, using only synthetic data — no client systems, no real customers, no production data.

---

## The business question
> A company wants to put multi-tenant customer data on a managed cloud backend. **Can it be built so that no tenant can ever read another tenant's data — and if an attacker destroys everything, can the business recover without paying a ransom?**

## The verified result
**The build holds, and the business can recover.** A penetration test from a customer's position confirmed that **tenant isolation is correctly enforced** — an anonymous client is blocked (`HTTP 401`), each signed-in user can read only their own rows, and a user explicitly crafting a request for another user's data gets back **0 rows**. Mapped to the **OWASP API Security Top 10**, this is **API1:2023 Broken Object-Level Authorization — tested, not vulnerable.** The baseline config audit (Supabase Security Advisor) surfaced two hardening findings: one — an over-privileged helper function — was **fixed and the fix proven by re-scan**; the other — leaked-password protection — is **Pro-gated on the free tier**, so free compensating controls were applied and the residual documented honestly with the production recommendation. Finally, the **ransomware-recovery loop was proven end to end**: an isolated, checksum-verified backup fully restored the system after total data destruction (`0/0/0` → `2/2/4` rows recovered), **with no ransom paid.**

## The report
**[Project 9 — Supabase Secure Build — Unified Evidence Portfolio (PDF)](Test-10-Final-Report-and-Client-Workflow/Project%209%20-%20Supabase%20Secure%20Build%20-%20Unified%20Evidence%20Portfolio.pdf)** — the full report: the cover, the secure-cloud architecture, each stage of the build, the penetration test with business impact, the fix-and-retest, the ransomware-recovery loop, and the evidence limits. Start with the cover and the Findings sections.

---

## How to read the evidence
Each stage is a `Test-NN` folder with self-describing screenshots; the build is reproducible from versioned SQL migrations in [`supabase/`](supabase/), and every finding stage has a plain-language `Test-NN-finding-notes.md` written record.

| Test | Stage | What it establishes |
|---|---|---|
| [01](Test-01-Scope-and-Authorization/) | Scope & Authorization | The rules of engagement, the Supabase own-project testing policy, and the **cloud-architect design** — all fixed before the build |
| [02](Test-02-Secure-Provisioning-and-Baseline/) | Secure Provisioning & Baseline | The project is created **secure by default** — Data API on, auto-expose new tables off, automatic RLS on |
| [03](Test-03-Schema-and-Migrations-as-Code/) | Schema & Migrations as Code | Tables and RLS are built as **versioned CLI migrations** — the whole backend is reproducible from code |
| [04](Test-04-Identity-Access-and-RLS/) | Identity, Access & RLS | Per-tenant RLS policies (`auth.uid() = owner_id`), grants to the **authenticated role only**, synthetic users seeded |
| [05](Test-05-Secrets-and-Surface-Hardening/) | Secrets & Surface Hardening | Key hygiene (`anon` public vs `service_role` secret) and the Security Advisor baseline — **P09-F1** and **P09-F2** found |
| [06](Test-06-Monitoring-and-Detection/) | Monitoring & Detection | Supabase Logs / Observability — failed auth and 4xx denials are visible for detection |
| [07](Test-07-Penetration-Test/) | Penetration Test | RLS isolation **holds**; OWASP **API1 BOLA — tested, not vulnerable** |
| [08](Test-08-Fix-and-Retest/) | Fix & Retest | **P09-F1 fixed and proven**; **P09-F2 mitigated** with an honest, documented residual |
| [09](Test-09-Backup-and-Ransomware-Recovery/) | Backup & Ransomware Recovery | Recover a company's data from an isolated backup after a fatal breach — **no ransom** |
| [10](Test-10-Final-Report-and-Client-Workflow/) | Final Report & Client Workflow | The unified PDF deliverable |
| [11](Test-11-Privacy-and-Responsible-Use/) | Privacy & Responsible Use | Responsible handling of evidence and AI-assisted work (standalone record page) |

## Findings at a glance (business impact)
| # | Finding | Severity | If this were a real company | Status |
|---|---|---|---|---|
| P09-F1 | Privileged helper function (`SECURITY DEFINER`) left executable by `anon` + `authenticated` | Low | Privileged database code is reachable by callers who should never touch it; a future bug in it becomes exploitable by anyone | **Fixed** |
| P09-F2 | Leaked-password protection disabled in Auth | Medium | Customers can set passwords already exposed in public breach dumps, making credential-stuffing easy | **Mitigated** (free compensating controls; full fix Pro-gated) |

> **Honesty note on P09-F2:** the full fix (the HaveIBeenPwned breach-password check) requires a paid Supabase Pro plan, so on the free tier it cannot be switched on. A strong password policy was applied instead (minimum length 12; upper + lower + digit + symbol required; current password required to change credentials). The Security Advisor therefore still reports this item (3 warnings → 1), which is **recorded as a documented residual with the production recommendation to upgrade to Pro** — not hidden.

## Controls that held
- **Tenant isolation (RLS)** — `auth.uid() = owner_id` is enforced in the database on every table. A user requesting another user's data gets **0 rows**, not an error that leaks existence.
- **No anonymous data access** — the `anon` role is never granted table access, so unauthenticated API calls are denied (`HTTP 401`) before RLS is even reached.
- **`service_role` key** — the key that bypasses RLS is treated as **server-side only**, kept out of the repo and out of all evidence.

## The recovery loop (ransomware resilience)
Proven end to end in [Test 09](Test-09-Backup-and-Ransomware-Recovery/): **back up** (`supabase db dump` to an off-platform file) → **verify integrity** (SHA-256 fingerprint, independently re-computed and matched) → **simulate a fatal breach** (truncate every table → `0/0/0`) → **restore** from the isolated backup → **verify full recovery** (`2` accounts, `2` profiles, `4` transactions — identical to the original). **No ransom paid.**

> **Honest boundary:** this proves the **recovery loop and the 3-2-1 backup principle** (multiple copies, off-platform, integrity-verified) — it is **not yet a true immutable / air-gapped vault**. The backup here lives on the same machine, so an attacker who genuinely owns both the cloud project and the physical box could also reach it. **True WORM immutability** — AWS **S3 Object Lock** in a separate account whose credentials the attacker never holds — is built in the AWS project later in this series.

---

## The platform
**Supabase** managed cloud (free tier) — organisation *Anyaugo Space-Tech*, project *project-09-supabase-secure-build*, region West EU (London). PostgreSQL + Row-Level Security + an auto-generated Data API (PostgREST) + Supabase Auth. The whole backend was built and tested from the Windows host via the **Supabase CLI** — the managed platform is itself the target, so no VM is needed. Two synthetic users (`[redacted-email]`, `[redacted-email]`) and a small fintech-style data model (profiles → accounts → transactions). Every record is invented; no real customers, credentials, or production data are involved.

## Tool stack (free / open-source — the real industry stack)
| Used here | Commercial / enterprise equivalents |
|---|---|
| **Supabase CLI** — schema + RLS as versioned migrations (Infrastructure as Code) | Flyway, Liquibase |
| **Supabase Security Advisor** — Postgres security linter (config baseline) | — |
| **Supabase Logs / Observability** — access + error monitoring | Splunk, Datadog (classical **Wazuh** SIEM arrives from Project 10) |
| `curl` + custom scripts — RLS / BOLA access-control testing | Burp Suite, Postman |
| `supabase db dump` + SHA-256 — backup & disaster recovery | Veeam, commercial backup suites |
| **OWASP API Security Top 10**, **NIST SP 800-115** (reporting / mapping frameworks) | — |

## Boundary & honesty note
This is a **controlled training-lab portfolio**, not a client assessment or a legal opinion. No client or company authorization is claimed; all work was done on a Supabase project the agency created and owns, on invented data, under Supabase's own policy that permits testing your own project. Observed lab results are kept separate from the **proposed** client workflow, and recommendations are marked as proposed practice, not completed work. Two residuals are stated plainly rather than papered over: the leaked-password fix is Pro-gated (P09-F2), and the recovery loop proves 3-2-1 resilience but not yet true immutability. See the PDF's *Assurance Boundaries* section for exactly what is and is not established.

---

*References: OWASP API Security Top 10 · NIST SP 800-115 · Supabase Security Testing policy. Prepared by Anyaugo Space-Tech Ltd., Security Training track.*

*© 2026 Anyaugo Space-Tech Ltd. Licensed under [CC BY-NC-ND 4.0](LICENSE) — share with attribution; no commercial use or derivatives.*
