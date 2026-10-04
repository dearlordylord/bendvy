# S-INTEGRATE shared contracts — draft for review

Discussion draft; no runtime implementation or capability acceptance. Based on
[reviewed execution split](s-integrate-execution.md), [source seams](s-integrate-seams.md)
and [exact E0–E11 trace](s-integrate-trace.md), inspected at `740383d`.
[#19](../tickets/18-integrated-runtime.md) retains its full scope. Trace preparation
may proceed now; integrated Bend implementation waits for #18 and interface review.

**Required** below means the reviewed trace/selected policy. **Proposed** names and
module boundaries are coordinator decisions to review/freeze before parallel code;
they are schematic obligations, not already checked Bend signatures.

## Shared declarations and owner return

| Boundary | Required behavior | Proposed shared interface obligation |
|---|---|---|
| Nominal schemas | Separate Motion and Health tokens/declarations; genuine Type Main/Aux/Ledger payloads, width4 arrays and every metadata field from the trace. No token aliases or scalar-only substitute. | Coordinator owns schema records, handle/provider types and complete Data observation records. Storage and systems import them. |
| Factory/world | One real threaded factory creates two worlds per schema; preserve returned owners on success and rejection. Trusted fixture lineage is explicit, not global root authority. | `create(factory) -> factory & creation`; every world operation returns its sole world owner with its result. Capacity rejection retains input owners. |
| Declared access | Closed callbacks receive arbitrary affine schema-specific providers and fresh declared operations; read returns provider plus projection, write returns provider. | Retain R-A/R-C1 rank-2 abstract provisioning and returned-handle composition. Concrete storage extraction stays inside trusted adapter. |
| Query/lookup | Required/present/absent/optional queries use logical entity order; full payload observations return owners. Distinguish Found, mismatch and missing. | Adapter returns world plus complete observation/result; index/list representations implement the same contract. |

Required payloads: Motion Position(coordinates,frame), Velocity(rates,moving),
MotionLedger(totals,epoch); Health Vitals(levels,reserve,class), Armor(layers,grade),
HealthLedger(totals,epoch). Selected/Tracked group, schema-specific Ping, Mode and
Audit also remain distinct declarations. Exact values and field order live in the
trace; no second fixture/constants table is introduced here.

## Identity, commands and transactions

- **Required:** a handle is durable; reservation consumes an ID immediately but its
  payload is pending until explicit D/T. Failed publication discards its spawn and
  payload, preserves the escaped missing handle and consumed reservation, and
  never reissues that handle. No tick-end flush. Live → component mismatch after
  removal; despawn → missing. Record raw IDs beside normalized labels.
- **Required selected divergence:** a foreign command returns `MissingEntity` and
  leaves receiver queue, rows and metadata unchanged, including colliding numeric
  IDs. Foreign lookup is also missing. Neither result implicitly aborts a system.
  Same-namespace dead-target behavior remains the trace's structural no-op case;
  no additional allocator/error policy is selected here.
- **Proposed:** command entry receives the actual handle and derives its target;
  no separate caller-supplied target. Return world plus command result, retaining
  any unqueued Type payload to the caller on rejection. Accepted staged payloads
  belong to the transaction and are released exactly once on failure; committed
  payloads transfer to pending FIFO, then live storage at the explicit barrier.
  Preserve the trace's public publication/disposal observations across these
  distinct ownership transitions.
- **Proposed:** storage extraction returns the actual cell owner and a reinsertion
  obligation; a callback returns that owner for reinsertion on every outcome.
  The transaction journal owns ordered inverse records for recoverable numeric
  writes on retained Main/Ledger arrays. B's two setters append separate inverses;
  failure applies 50→30→20 and Ledger201→101. Observations never replace owners.
- **Required:** finish(success) preserves writes and publishes staged commands,
  messages and observable marks; finish(failure) restores recoverable ECS writes
  and drops that system's staged publications. A's earlier commit survives B.
  Allocation consumption and lexical captures are outside this rollback. Structural
  disposal consumes removed Type owners exactly once at the explicit barrier.
  Arbitrary destructive callback restoration is an unresolved separate capability.

## Publication, readers and dispatcher

**Proposed hooks:** transaction begin/finish and explicit structural apply return
owners plus commit/apply descriptions consumed by the log/mark adapter. Readers
own their positions independently of retained payload cells; removed/despawned
records retain handles after deletion. These hooks specify ownership transfer,
not a required internal journal/log representation or raw generation rewind.

| Boundary | Required observable rule |
|---|---|
| Begin/read | Register the actual Fast/B base instances; read each instance's saved message/change/lifecycle boundaries. Reads preserve log/world owners. |
| Success | Advance only the invoked reader's reference-defined positions. Commit publishes after its run tick; B sees its post-run event later without reading its same-run changed stamp. |
| Failure/retry | Do not complete the failed reader; retry sees the same retained messages/lifecycle values and lag. Restore observable failed write marks; preserve other readers. |
| Skip | No callback or capture increment. Advance message boundary only, retaining change/removal/despawn boundary. |
| Retention | Preserve registration-aware holds and exact public E11 capacity behavior: whole message batches versus individual lifecycle records; expose loss/lag and preserve first-failure/same-instance retry at capacity65536. |

**Proposed dispatcher boundary:** preflight all declared/provisioning requirements
of the actual nested schedule before invoking any system. Ledger/Audit are E10's
exercised missing-requirement cases. Provision returned owners,
execute sequentially, and propagate B/code7 through nesting while suppressing both
tails. Explicit D and T remain authored operations. Schedule owner returns distinct
A/B/Fast capture owners; both returned-owner and regenerated once-only closure
styles preserve increments through failure and never increment on skip. Audit is
an actual external service effect, outside ECS rollback. Missing requirements use
E10's exact result and invoke no system/service; state changes follow authored T.

## Freeze and verify before parallel implementation

Coordinator freezes nominal types, owner/result shapes, inverse obligations,
publication hooks, reader boundaries and exact fixture inputs. Review the proposed
signatures against actual Bend types/affinity before workers share them. Each shared
file has one owner; storage, transactions, readers and dispatcher receive separate
module ownership after that freeze. Failed expressive/ownership controls trigger a
recorded redesign, never a narrower silently passing interface.

Use one canonical observation contract: every query/payload/resource field,
ascending logical rows, lookups, pending visibility, raw reservations, reader values
and lag provenance, dispatcher outcomes, captures, tails and real Audit effects.
Keep physical representation incidental; separate approved foreign divergence,
internal adapter checks and compiler controls. E0–E11 remain the exact trace,
including public large-overflow lanes; compact encoding checks every element and
cannot hide failed-ID consumption. Lifecycle public debug diagnostics and event
view lag have distinct provenance; timing fields do not enter semantic equality.

Draft/falsify exact integration laws before implementing their subjects; obtain
specific approval before general proofs. New dependencies and performance thresholds
retain their gates. Fresh TS/Native/JS traces, intended negative/control pairs and
compiling semantic mutants are #19 evidence, separate from #18/model proofs.
No production layout, root/reuse/exhaustion, general Local, destructive-recovery or
arbitrary Type message fan-out policy is chosen. Retain those full-core follow-ups
and measure equivalent integrated workloads before performance acceptance.

Astra reviewed this draft on 2026-10-04: required scope retained; clarified staged
payload ownership, complete preflight and the exact public overflow retry boundary.
