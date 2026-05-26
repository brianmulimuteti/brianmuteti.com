---
title: "Centralised Observability for Core Banking Systems"
subtitle: "An Elastic Stack platform that cut incident MTTR by ~90% across three mission-critical banking systems"
summary: "Designed and rolled out a centralised observability platform — metrics, logs, uptime — spanning the bank's core systems, replacing fragmented per-system tooling with a single operational view."
role: "Tech lead — architecture, rollout, dashboards, handover to operations"
context: "A Tier-1 East African bank"
stack:
  - "Elasticsearch"
  - "Logstash"
  - "Kibana"
  - "Metricbeat"
  - "Filebeat"
  - "Heartbeat"
  - "Linux"
order: 2
published: true
publishDate: 2026-03-01
---

## Context

The bank's core platforms — the deposits and lending engine, the cards platform, and the agency banking gateway — each had their own monitoring. Operations relied on a patchwork of vendor consoles, log files on individual servers, and tribal knowledge. When something went wrong, the diagnostic loop began with phone calls.

The mean time to identify the root cause of a production incident was hours, not minutes. Almost all of that time was navigation: which server, which log, which dashboard, which person to call.

## Problem

Three fundamental gaps:

1. **No correlation across systems.** Most real incidents span multiple platforms — a slow upstream causes a backlog downstream — but every dashboard was single-system.
2. **No unified log search.** SSH-and-grep on the right server was the diagnostic tool of last resort. It scaled poorly under pressure.
3. **No proactive health signals.** Operations learned about most incidents from customer complaints, not from monitoring.

## Approach

I designed and led the rollout of a centralised Elastic Stack platform spanning all three core systems. The architecture was deliberately conventional — Metricbeat for system metrics, Filebeat for application logs, Heartbeat for synthetic uptime probes, Logstash for ingest pipelines, Elasticsearch for storage, Kibana for visualisation.

The non-conventional work was in the ingest pipelines and the dashboard design. Each system's logs had its own format, its own timestamp conventions, its own way of expressing transaction identifiers. The ingest pipelines normalised them into a common schema — a request that began on the cards platform and ended on the lending engine could be followed end-to-end with a single trace ID.

Dashboards were designed for the engineers and operators who would use them under pressure — not for executives. The first screen of every dashboard answered one question: *is this system healthy right now?* Latency, error rate, throughput, and a synthetic heartbeat status, side by side. Drill-down was a click away but never required for the first answer.

## Key decisions

**Log enrichment at ingest, not at query time.** Logstash pipelines extract transaction identifiers, anonymise customer references, and tag log lines with a normalised system name and environment. Querying becomes simple because the structure is already in place.

**Synthetic probes treated as first-class.** Heartbeat checks every critical service every minute from the operations network. Half of the early "incidents" surfaced by the platform were synthetic probes catching slow degradation before customer-facing failures. That bought us minutes that previously did not exist.

**Dashboards owned by the teams that operate the systems.** Each core system had a primary operations team. I built the first dashboards for each, then handed authorship over. Within months, the most-used dashboards were not the ones I built — which was the point.

## Outcome

Mean time to detect dropped from hours to minutes. Mean time to resolve dropped by roughly 90% on the incidents that were previously slow because of navigation, not because of the underlying repair.

More importantly, the cultural shift: the first action during an incident moved from "who do I call" to "what does the dashboard show." Phone calls became the second step, not the first.

## What I'd do differently

I would invest earlier in distributed tracing alongside metrics and logs. The platform answers *what is broken* and *where the symptom is* very well; tracing answers *which call path caused this* in a way that aggregated logs cannot match. Retrofitting tracing to systems already in production is harder than building it in from the start.

I would also push for log retention tiers from day one. Hot, warm, and cold storage make a meaningful cost difference at the volumes that banking platforms generate, and the time to set them up later — once everything is already running — is non-trivial.