# Test 06 — Monitoring & Detection
### Project 09 — Supabase Secure Build · detection surface for a managed backend

## Objective
Establish where security-relevant activity is observed, so that the Test-07
attacks (and real-world incidents) are detectable.

## Honest platform note
Supabase is a **managed platform** — you cannot install a host agent (e.g. Wazuh)
on it. In this cloud series, **Wazuh becomes the SIEM from Project 10 onward**
(Cloudflare / IaaS, where a server runs the agent). For a managed BaaS, the
detection layer is Supabase's **native observability + logs**, optionally
forwarded to an external SIEM via **Log Drains** (paid).

## Monitoring surface (native)
- **Observability / Reports** — per-service health for API Gateway, PostgREST
  (Data API), Database, Auth, Edge Functions, Storage, Realtime; plus DB
  resource metrics (connections, CPU, memory, disk, slow queries).
- **Logs** — unified log explorer across Postgres, PgBouncer/Supavisor, Auth,
  Storage, Edge, Realtime; filterable by log type and HTTP level (2xx/4xx/5xx).

## Detection strategy (what we watch)
- **Auth logs** → failed logins / brute force, unexpected sign-ins.
- **API / PostgREST logs** → denied requests (RLS / permission), anomalous volume.
- **Database logs** → errors, unusual queries.
- **service_role usage** → should be server-side only; never from a client.

## What the evidence shows
Live telemetry is already flowing from the build/seed activity (~115 PostgREST
requests, 26 API-gateway requests, Auth warnings), confirming the monitoring
captures real activity. The baseline is quiet of attacks.

## Detection proof → Test-07
The penetration test in Test-07 generates real attack traffic (anonymous reads,
cross-tenant access attempts). Those requests surface in these same logs and are
captured there as the detection evidence — closing the "watch → attack → see it"
loop.

## Evidence files
- `Test-6A-supabase-observability-overview-metrics.png`
- `Test-6B-supabase-observability-service-health.png`
- `Test-6C-supabase-logs-explorer.png`

## Scope
All testing performed against infrastructure I own and control, in an isolated lab environment.
