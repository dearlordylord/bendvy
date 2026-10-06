# S-API-AUDIT — blind ECS consumer evaluation

GitHub #25; delivered bounded audit with a blocked application outcome.
[Corrected report](../reports/blind-ecs-api-audit.md); follow-up #26.

User-authorized 2026-10-06. Full-core parent #1; interface integration connects
to #24. This is an API usability/capability audit, not performance acceptance
or approval of a production API.

## Question and input

Can an independent application author use the current interfaces to write a
small idiomatic ECS simulation while respecting Bend types and affine ownership?
Use the exact concrete-v3 29-module source closure
`a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55`.
The coordinator supplies source bytes with sibling imports preserved, installed
Bend guide/Base and pinned Rust Bevy, bevy-ts and Bend compiler/runtime sources.
Do not supply optimization history, benchmark results, integration reports,
previous reviewer findings or suggested engine-specific workarounds.

## Blindness and ownership

Start a fresh agent with `fork_turns=none`, not a prior implementation worker.
Its source snapshot has no Git history or project documentation. Evaluation is
protocol-isolated, not a filesystem security sandbox: record its inputs and
allowed reads, preserve first impressions before any coordinator help, and
disclose any contamination. Library sources are read-only. The consumer owns
only its application and evidence; root owns integration and independent replay.

## Finite application contract

Attempt one world with Position/Velocity/Health and optional Armor/tag; separate
user-authored movement and damage systems; fixed ticks; deferred spawn, insert,
remove and despawn with an explicit barrier; a small resource; hit/death output;
a read-only observer. At least one component must retain an actual affine Type
payload. Explicit typed schema declarations are allowed. No schema DSL/generator
is required. Establish equivalent natural Bevy/bevy-ts code from pinned sources.

A supported example must use actual client interfaces: copying existing engine
gameplay or mutating storage/caches/journals is not independent application code.
Record absent capabilities rather than silently faking them. A bounded failing
audit may complete its research deliverable without passing simulation gates.

## Evidence and return conditions

1. Freeze first impressions and attempted application before design hints.
2. Record public entry points, commands, complete outputs, exact source/tool pins,
   failed attempts and distinctions between unsupported API and failed client.
3. Try undeclared-access, cross-schema, writes-through-read and duplicate-owner
   negatives with positive controls; require intended rejection, not timeouts or
   unrelated diagnostics.
4. Report ECS usability separately from unavoidable Bend annotations/ownership.
   List concrete minimum interface changes and explicit follow-up gates.
5. Root replays supported examples and controls, then compares findings with the
   source and SPEC. If a full example is blocked, preserve that result and the
   exact missing seam before considering engine changes.

No new laws/proofs/dependencies, compiler/kernel/reference edits or Canonical
Defense edits. Checker5s, emit30s, runtime5s, compiler120s. Optimization is paused;
JS/TS<=1 and Native/TS<=0.5 remain open mandatory product targets. A successful
audit does not pass full22, universal refinement, performance or production API
adoption.
