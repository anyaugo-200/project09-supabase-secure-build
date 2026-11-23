# Test 09 — Backup & Ransomware Recovery
### Project 09 — Supabase Secure Build · recover a company's data without paying ransom

## Objective
Prove the data can be recovered from an **isolated backup** after a fatal breach —
the scenario where an attacker compromises both the cloud project *and* the physical
machine and destroys the data — with **no ransom paid**.

## The recovery loop (backed up → verified → destroyed → restored → verified)
1. **Backup** — `supabase db dump --linked --data-only --schema public` wrote all 8
   rows as INSERT statements to an off-platform file (`Test-09-backup-data.sql`). (Test-9A)
2. **Integrity fingerprint** — SHA-256 of the backup =
   `932004d6e3719fca66dbd4435a78bdd36d86d79e70de56112a3f3fd0641d2bde`; independently
   re-computed and **matched**, proving the backup is intact and untampered. (Test-9B)
3. **Fatal breach (simulated ransomware)** —
   `truncate public.transactions, public.accounts, public.profiles cascade;`
   destroyed all application data; a count confirmed **0 / 0 / 0**.
   (Test-9C-1 destructive-op confirmed; Test-9C-2 data destroyed)
4. **Restore from the isolated backup** — replayed the backup SQL into the empty
   tables. (Test-9D)
5. **Verify full recovery** — everything back and identical to the original:
   **2 accounts** (Alice Current, Bob Savings), **2 profiles** (Alice/Bob Tester),
   **4 transactions** (Coffee, Salary, Snack, Bonus). **No ransom paid.** (Test-9E)

## Outcome
The complete disaster-recovery loop is proven: a verified, off-platform backup fully
restored the system after total data destruction. The business recovers its data
without paying — the whole point of the exercise.

## Honest boundary (stated plainly, as the report will)
- This proves the **recovery loop + the 3-2-1 principle** (multiple copies, off-platform,
  integrity-verified) — **not yet a true immutable/air-gapped vault.**
- The backup here lives on the **same machine**, so an attacker who genuinely owns both
  the cloud *and* the physical box could also reach and destroy it.
- **True immutability** — AWS **S3 Object Lock** in a **separate account** whose
  credentials the attacker never holds — is built in the **AWS project (12)**. There the
  backup becomes WORM and survives a combined cloud + physical compromise.
- Infrastructure-as-code (the migrations) is the reproducible **schema** half; this backup
  is the **data** half. Together they rebuild the whole system from code + an isolated copy.

## Evidence files
- `Test-09-backup-data.sql` — the backup artifact (INSERT-format, 8 rows)
- `Test-9A-supabase-db-dump-backup-created.png` — backup created
- `Test-9B-backup-sha256-checksum.png` — integrity fingerprint (matches reference)
- `Test-9C-1-breach-destructive-op-warning.png` — destructive op consciously confirmed
- `Test-9C-2-breach-data-destroyed.png` — breach: 0 / 0 / 0
- `Test-9D-restore-executed.png` — restore run from the backup
- `Test-9E-data-recovered.png` — full recovery: 2 / 2 / 4 + all names

## Scope
All testing performed against infrastructure I own and control, in an isolated lab environment.
