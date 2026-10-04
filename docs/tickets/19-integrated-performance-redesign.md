# S-PERF — implement and evaluate an experimental indexed adapter

**[GitHub #20](https://github.com/dearlordylord/bendvy/issues/20). Astra Spec-reviewed planned work.** Follow-up to S-INTEGRATE
[#19](https://github.com/dearlordylord/bendvy/issues/19), full-core parent #1.
[Review](../reviews/s-integrate-final-spec.md). This authorizes no production
layout, numerical performance threshold, dependency or new universal proof.

## Problem and bounded outcome

The integrated owned-list runtime preserves the reviewed ECS observations but
completed Dense/Sparse and JS Readers samples regress against bevy-ts. Dense1024
and some larger sampling processes exceed five seconds. Implement one alternative
experimental adapter, connect it to the same runtime seam and determine whether
its measured behavior merits a separate production-adoption decision. A design
report or isolated indexed kernel alone does not deliver this ticket.

Use the current owned-list implementation as the retained baseline. Investigate
actual per-row lookup, query selection, write journals, mark updates, command
application and observation costs. Repeated list traversal is source-supported;
its share of elapsed time remains a measurement question. Preserve full authored
observations while distinguishing their construction from diagnostic encoding.

Design preparation may proceed against published #19 evidence. Candidate runtime
and comparative measurements require the corresponding #19 trace/access/ownership
subjects and all five workload contracts to be frozen, including the final
transaction/lifecycle and corrected-memory outcomes. A recorded bounded failure
is an admissible baseline; an unfinished gate is not a passing prerequisite.

## Work and acceptance

1. **Freeze design and evidence before implementation.** Pin #19 source closures,
   workload inputs, raw samples and failures. Record the candidate's entity-ID to
   slot mapping, ascending logical membership, capacity bounds, affine Type column
   ownership, missing/foreign lookup and relocation/destruction boundaries. Show
   how declared callbacks return owners and how inverse or retained-owner journals
   preserve read-your-writes and rollback. Draft/falsify any new exact candidate
   statements before implementing their subjects; obtain independent design review.
   Proofs against new laws still require their specific approval.
2. **Implement one bounded candidate.** Use indexed logical-ID access plus stable
   ordered membership, with genuinely owned Type payloads. Seek to remove repeated
   per-row full-list scans and redundant journal work without removing any authored
   write/read or transaction boundary. Do not assume mutable-column expressibility
   or restoration: pair the proposed owner-return path with intended negative
   controls before extending it. If that gate fails, retain the executable failure
   and propose a concrete redesign rather than silently switching to Data payloads.
3. **Join the existing runtime.** Route actual declared providers, closed sequential
   dispatch, transactions, explicit barriers and registered readers through the
   candidate. Exercise first/middle/last churn, repeated targets, relocation and
   failed/retried transactions. Verify complete ascending queries after each
   lifecycle boundary and full returned payload fields; do not benchmark only
   favorable head operations or unconnected storage helpers.
4. **Repeat capability and mutation gates.** Run both nominal schemas and both
   capture styles through the complete main trace, public retention cases, intended
   access negatives and compiling semantic mutants. Add candidate-specific controls
   for wrong ID-to-slot association, lost/duplicated relocated ownership, order and
   stale mapping. Preserve failed-reservation consumption, FIFO, prior commits,
   cursor/mark/publication rollback and foreign MissingEntity with unchanged receiver
   queue. Normalize physical slots only; preserve logical identity and every field.
5. **Measure the same five workloads.** Dense, Sparse, Lifecycle, Readers and Failed
   Transaction retain 64/256/1024 initial live entities and the frozen iteration
   sequence on Native O3 (one worker, GPU off), JS and pinned TS. Setup, warmup and
   final serialization stay outside the inner interval; dispatch, barriers and
   authored intermediate observations remain inside. Each sample has fresh state,
   complete semantic validation and a supplemental checksum. Collect seven rotated
   repetitions, raw values, variability and per-workload ratios; failed cases receive
   explicit outcomes rather than ratios.
6. **Resolve timing and memory limits.** Align Readers timing-adapter preregistration
   on TS and Bend while retaining the exact callbacks, iteration inputs, diagnostics
   and reader identity; compare its complete output to the unchanged authoritative
   reference before sampling. Historical TS per-iteration descriptor construction
   versus Bend preregistration remains a labeled comparison limit, not a performance
   win. If timer quantization is material, repin the same longer work/batch on all
   backends before collecting replacement samples. Use independently controlled
   child peak-RSS collection without inherited launcher peaks; report whole-process
   scope, retained live count, command/log occupancy and reader lag, marking anything
   unavailable explicitly. Preserve superseded raw evidence and method failures.
   Add a quiet FailedTxn adapter that executes the identical registered callbacks,
   writes, queries, current/historical lookups, reader/audit effects, reservations
   and barriers. Validate all fields and final results against the existing full
   Bend diagnostics and unchanged TS reference before sampling; move diagnostic
   serialization outside the interval rather than suppressing authored work.
   Restore stable positive/negative checking and builds under the existing limits;
   preserve the recorded byte-identical-source checker timeout as baseline evidence.
   Instrument actual retained physical log entries/holders, staged and pending
   commands, and reader positions/unread/lag at workload boundaries. Report peak
   occupancy and lag separately from whole-process peak RSS; final drains never
   establish zero physical retention. Record any unavailable metric explicitly.
7. **Review and decide.** Obtain independent Spec and Standards reviews. Deliver
   implemented candidate sources, exact replay commands/hashes, per-capability
   pass/fail/unresolved results, measured or blocked outcomes for every requested
   workload/size, and a recommendation to continue, reject or redesign. A useful
   bounded negative can complete this experiment only with the failed capability,
   reason, concrete follow-up and return condition recorded. Production adoption
   remains a separate decision after its actual capability/performance evidence.

Retain five-second checker and runtime limits, separately recorded build limits,
task-owned process cleanup and dependency-free tooling unless a concrete new
dependency receives approval. Do not erase a deadline failure by increasing its
limit or by replacing full observations with a checksum-only program.

Native substantially faster than bevy-ts and JS at least comparable remain
mandatory product requirements. Numerical acceptance thresholds require explicit
approval. Neither an isolated speedup nor closure of this bounded experiment
establishes product performance or universal runtime refinement.

## Retained scope and closure boundary

This is one executable experimental implementation/evaluation ticket, with its
design freeze as the first gate. A separate design-only ticket is unnecessary
unless an ownership or policy decision blocks that gate. Production integration
or layout adoption, broader performance acceptance and new proof packages remain
separate follow-ups, not implicit second stages of a passing microbenchmark.

Allocator reuse/exhaustion, unforgeable root authority, arbitrary destructive
Type recovery, general Local, dynamic provisioning and parallel compute retain
separate packages. Do not modify Canonical Tower Defense. Simulation and later
application integration continue only through their existing capability and
performance prerequisites; this ticket does not waive them.
