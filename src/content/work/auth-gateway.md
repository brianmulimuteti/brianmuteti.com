---
title: "Modernising a Multi-Country Customer Authentication Gateway"
subtitle: "Zero-downtime modernisation of a legacy authentication gateway across six country deployments"
summary: "Replaced a legacy Java authentication gateway with a modernised Spring Boot service, including an email-fallback path, deployed in sequence across six country subsidiaries with zero customer downtime."
role: "Engineering lead — design, rollout sequencing, cutover, post-rollout monitoring"
context: "A Tier-1 East African bank"
stack:
  - "Java"
  - "Spring Boot"
  - "Linux"
  - "Bash"
  - "Elastic Stack"
order: 4
published: true
publishDate: 2025-12-01
---

## Context

The bank's customer authentication gateway — the system that issues one-time codes used to authorise card transactions and customer-facing operations — was a legacy Java service that had been in production for years. It worked, but it had aged: the codebase was difficult to change safely, the SMS-only delivery path had no fallback if the SMS gateway was degraded, and observability was thin.

The same gateway code was deployed in six country subsidiaries. Any modernisation had to roll out across all of them without breaking authentication for any of them — because authentication is a system that, when it fails, fails very visibly and very expensively.

## Problem

Three pressures coming together:

1. **Operational fragility.** The legacy gateway had no fallback path. SMS gateway degradation, which happened occasionally, meant authentication degradation, which meant card transactions failing.
2. **Aging codebase.** Bug fixes were taking longer than they should because the surface area for unintended side effects was large.
3. **Cross-country consistency.** Six deployments, six teams, six change windows. The rollout had to be sequenced and controlled, not parallel.

## Approach

I designed the modernised service to be a drop-in replacement for the legacy one — same external contracts, same expected behaviour from the perspective of the calling systems — with an email-delivery fallback path added. The internal codebase was rebuilt on a modern Spring Boot foundation, with structured logging, health endpoints, and observability hooks designed in from the start.

Rollout was sequenced country by country. The first country went live during a low-volume window, with the legacy service kept on standby and the deployment reversible in under five minutes. We watched closely for a full transaction cycle — authentication request, code delivery, code validation, transaction outcome — across both SMS and email paths. Once one country had been stable for an agreed observation period, the next country went.

The rollout took several weeks and was deliberately patient. The cost of going slow was a few weeks; the cost of going fast and breaking authentication in one country would have been measured in customer trust and regulator attention.

## Key decisions

**Drop-in compatibility was non-negotiable.** Every upstream caller — card switches, internet banking, ATM networks — had to see no change in contract. The modernised gateway speaks exactly the same wire protocol on its public interface; the modernisation is entirely internal.

**Fallback as a path, not an emergency switch.** The email-delivery fallback is a normal code path that handles delivery when SMS is degraded, not a manual toggle someone has to flip during an outage. This means the fallback is tested by being used routinely under partial degradation, not theoretically by being switched on once a year.

**One country at a time, with a defined observation window.** No country went to production until the previous one had been stable through a full business cycle. This was the single most important rollout decision — it traded calendar time for safety and was clearly worth it.

## Outcome

All six country deployments completed without customer-visible downtime. The fallback path has since served real traffic during SMS degradation events, exactly as designed. The new codebase has measurably shorter change cycles — fixes and small enhancements that used to take days now take hours.

## What I'd do differently

I would invest earlier in a synthetic transaction probe that exercises the full authentication path — request, delivery, validation — as a continuous health check, separately from any real customer traffic. We had this in pieces; a single end-to-end probe would have made the observation windows during rollout more decisive.