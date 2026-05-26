---
title: "Scorecard Governance Platform"
subtitle: "A multi-tenant maker-checker platform for production banking data across six country subsidiaries"
summary: "Built solo end-to-end: enforces four-eyes governance over every change to scorecard data, with dynamic field allowlists, automatic SLA expiry, immutable audit, and rollback through the same flow."
role: "Sole engineer — architecture, backend, frontend, scheduler, security, handover"
context: "A Tier-1 East African bank"
stack:
  - "Java 21"
  - "Spring Boot 4"
  - "JHipster 9"
  - "Angular 17"
  - "PostgreSQL"
  - "Redis"
  - "Quartz"
  - "JWT (RS256)"
order: 1
published: true
publishDate: 2026-04-24
---

## Context

A Tier-1 East African bank with operations across six country subsidiaries needed to govern changes to its scorecard data — the reference data behind credit decisions, segmentation, and analytics. Each subsidiary held its own production database. Changes were being made by direct database access, with no enforced approval workflow, no immutable record of who changed what, and no SLA on review.

For a regulated bank, that was a quiet but serious problem: a single bad change to scorecard data could distort credit decisions for a whole country, and there was no way to prove afterwards who had authorised what.

## Problem

The governance gap had three concrete dimensions:

1. **No enforced separation of duties.** Any analyst with database access could change scorecard fields. There was no system-enforced second pair of eyes.
2. **No auditable history.** Changes were sometimes accompanied by spreadsheets and emails, sometimes not. Reconstructing a change retrospectively was painful or impossible.
3. **No country-level isolation.** Each subsidiary's data was in its own database, but the tooling to safely write to those databases was ad hoc.

## Approach

I designed and built a single platform that takes every proposed change through a strict workflow:

> Maker submits → System validates → Checker reviews → Approved write committed to the target country's database → Snapshot captured → Audit log written

The Maker selects a table, a country, a record identifier, and the fields to change. The system fetches the current values from the target database so the Maker is reasoning against live data, not a stale copy. On submission, the system assigns an independent Checker — online first, then least-workload fallback — and notifies both parties by email. Pending requests automatically expire after 48 hours, with a reminder at 24 hours.

A request can never be approved by the user who submitted it. Approvals on prior-month data are blocked at validation time. Rollbacks travel through the same maker-checker cycle as forward changes — there is no "admin override" path that escapes the audit trail.

## Key decisions

**Field allowlist driven by YAML, not code.** Every editable table and field — with its type, length, regex, and range constraints — is declared in a configuration file. Adding a new editable entity is a config change plus a Liquibase changeset, not a deployment of new business logic. This kept the system reusable as new tables came under governance.

**One Hikari pool per country-table pair.** Instead of routing through a single shared connection pool, the platform maintains a dedicated pool for each `(table, country)` combination, keyed by configuration. This gave clean isolation, per-country credentials, and predictable failure modes — if Uganda's DB was unreachable, Kenya's flow was unaffected.

**Approvals lock the request row.** I used a pessimistic database lock on the change request during approval to prevent two checkers from racing on the same request. With time-bound SLA reminders running on a scheduler, this turned out to matter more than I expected.

**Immutable audit, including system events.** Audit entries record actor, role, action, before/after JSON snapshots, IP, and session. System-initiated events (expiry, system rollbacks) write entries with a null actor — auditable, not falsifiable.

## Outcome

The platform was delivered solo — backend services, Angular frontend, Quartz scheduling, email templating, security, deployment scripts, and operator documentation. It is now in production use by the data analytics and credit teams as the governing workflow for scorecard changes across all six subsidiaries.

Handover included a complete technical operations guide, configuration playbooks for adding new tables and countries, and a troubleshooting guide built from issues hit during build. New tables can now be brought under governance by the operations team without engineering intervention.

## What I'd do differently

If I were starting again, I would push harder for an event-sourced audit log rather than a synchronous append. The current design is correct, but a domain-event stream would have made downstream analytics (frequency of rejection per checker, average time-to-approve per country) free instead of requiring purpose-built reporting on top of the audit table.

I would also separate the workflow service from the target-write service more aggressively. Right now they share a transactional boundary in places; pulling them apart would make the target-write side easier to replay and easier to test in isolation.