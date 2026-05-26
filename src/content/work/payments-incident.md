---
title: "Restoring a National Payments Service During a High-Impact Outage"
subtitle: "Incident leadership during a high-impact outage on a national interbank payments rail"
summary: "Led the response on an outage affecting bank-to-bank transfers — log forensics, root-cause isolation, emergency rollback, and a hotfix — while keeping stakeholders informed throughout."
role: "Incident lead — diagnosis, decision, rollback, post-incident review"
context: "A Tier-1 East African bank"
stack:
  - "Java / Spring Boot"
  - "Elastic Stack"
  - "Linux"
  - "Bash"
  - "On-call tooling"
order: 3
published: true
publishDate: 2025-09-01
---

## Context

A national interbank payments service — used for real-time bank-to-bank transfers across the country — began failing in the middle of a normal business day. Customers attempting to send money to other banks were seeing errors. Other banks attempting to receive payments through the same rail were timing out.

For a Tier-1 bank, this is the kind of incident that does not have a comfortable resolution. Every minute of degraded service is real money the bank's customers cannot move, and every minute is visible to the central bank, to peer banks, and to social media.

## Problem

The early signal was ambiguous: error rates were rising on outbound transfers, but the application servers themselves looked healthy. CPU was fine, memory was fine, the application was responding to its own health checks. The errors were intermittent — perhaps two-thirds of transactions failing, one-third succeeding.

The hardest part of the early window was not technical. It was the pressure to *do something* — restart the service, fail over, push the most recent change backwards — without knowing whether any of those would help or harm.

## Approach

I worked the problem in two parallel tracks:

**Track one: contain the customer impact.** Communicate clearly upward and outward — operations, customer service, communications — that the issue was real, that it affected outbound transfers specifically, and that we were investigating. Holding the line on honest, frequent updates kept the wider organisation from making the situation worse with conflicting workarounds.

**Track two: find the actual cause.** I went to the logs. Not the application's own logs first — the *downstream dependency* logs. Outbound transfers in this system depend on a chain of validation calls. One of them was timing out under load, and the timeout was being misinterpreted by the calling service as a transient error rather than a fatal one, leading to a partial-success / partial-failure state that was confusing every metric.

Once the upstream call's behaviour was clearly identified, the right move became visible: the most recent deployment had changed how that call was wrapped, and the new wrapper was swallowing the timeout signal. I executed an emergency rollback to the prior version, watched the error rate drop to baseline within minutes, then worked with the engineering team to ship a forward fix the same evening.

## Key decisions

**Look downstream first.** When the application itself looks healthy and the error rates are partial, the cause is almost always in a dependency. Spending the first minutes inspecting the application's own metrics is the most common diagnostic mistake on this kind of incident.

**Rollback, then fix.** With the cause identified, I made the call to roll back rather than hotfix forward. A rollback to a known-good state is faster and lower-risk than a hot patch. The forward fix went out hours later, under normal change control, with the pressure off.

**Frequent, factual updates.** I committed to a fifteen-minute update cadence to stakeholders during the incident, even when the update was *no new information*. The discipline of saying "we are still investigating, here is what we have ruled out" is more valuable in a crisis than people expect.

## Outcome

Service restored. The window of customer impact was contained to a single afternoon, not a multi-day saga. The post-incident review surfaced not just the technical fix but a process gap — the timeout wrapping change had passed peer review without the reviewer noticing the swallowed signal, because the test coverage for downstream failure modes was thin. That gap got closed.

## What I'd do differently

The diagnostic time would have been shorter if downstream dependency timings had been visible on the same dashboard as application health from the start. The observability platform we built afterwards now has exactly this — calls out, latency to each, error rates per dependency — directly alongside the calling service's own metrics. We were not flying blind during the incident, but we were having to assemble the picture from too many sources under pressure.