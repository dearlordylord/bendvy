# Affine JS node reuse — draft for discussion

Follow-up under #21/#24; **not compiler-change approval or a proved optimization**.
The full ECS scope and JS parity / Native>=2x targets remain unchanged.

## Evidence and source seam

The [emitted probe](../../experiments/s-prep/js-affine-owner-reuse/README.md)
removes eight Held/Cache constructions per callback and preserves bounded
original/suppressed transaction traces. Sampled allocations decrease in one run;
JS timing still misses parity. This motivates a compiler experiment, not adoption.

Pinned Bend2 `a950fd6`, `bend2/comp.ts`: `js_expr`'s Ctr branch
(2962–2976) emits a fresh object for ordinary constructors. `js_match`
(3038–3080) opens fields and calls `js_func` with null branch type context;
it does not transport a reusable constructor-origin token. JS shape alone is
insufficient evidence that a node has no surviving aliases.

## Proposed bounded experiment

Carry checked affine ownership, constructor identity and origin/liveness evidence
through lowering. Permit same-constructor container reuse only after every use
of its old projections is accounted for. Evaluate new fields in original order
into temporaries, then assign and return the consumed container. Reuse is a
physical implementation token, never a second typed owner. Start with private
Held/Cache containers; preserve ordinary allocation on every unsupported case.

Do not infer uniqueness from object shape, a Type spelling, or one use in emitted
JS. Duplicable values, exported/FFI aliases, captured projections, uncertain kinds
and escaping nodes require explicit treatment or fallback. Data snapshots,
inverse records, queue/list nodes and generic Tuples remain immutable in this
bounded proposal. Arbitrary affine component payloads must remain supported.

## Required evidence before adoption

- Pin the compiler/source variant and document its ownership eligibility rule;
  no changes to the proof kernel or read-only reference checkout.
- Test retained Data snapshots, captured aliases, duplicable constructors and
  unsupported/FFI boundaries with negative controls, plus owned-array payloads.
- Re-run both schemas' true-old, inverse order, suppressed setter, marks,
  queue/rollback and complete fields; retain foreign-handle, cross-schema,
  undeclared-access and write-through-read controls.
- Pass the exact-source full22 gates. Current Cemit30 failures remain failures.
- Measure equivalent complete JS/Native workloads against fresh pinned bevy-ts;
  constructor counts and one sampled heap/timing result do not qualify targets.

Any new universal law/refinement claim requires its exact approval before proof.
External compiler implementation requires explicit authorization. Native transport
and dropping remain separate profiled follow-ups; JS reuse does not solve them.
