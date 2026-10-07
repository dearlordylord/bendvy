# Indexed seek-view fusion — draft proposal

Read-only source investigation, awaiting independent review. No implementation, compiler changes, laws, proofs, measurements or performance acceptance.

## Observed mechanism

Frozen Column SHA `3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a`. Generated ten-application JS SHA `1216f69f743872e126b783fbd61b05a52ced2acfc6eaa8d1b35a38e3c1c6c499` in `.artifacts/frontier-indexed-array-view-prepared-regression/candidate/workshop.js`.

Its five `indexed_seek_view` specializations rebuild `HandoffCon` and allocate `Choice` on Inspect, then allocate `Inspect` on Advance. Each row burns two fuel steps. The emitted loop already uses tail iteration; the source lead is transient owner/phase construction, not elimination of recursion. Reconstruction at terminal before/refusal is necessary to retain the untouched row owner.

## Private seam

Keep public `indexed_seek_view` and its function quantities unchanged. In particular, explicit Choice booleans may contradict target/id and remain observable. Change only the forward branch of `indexed_prepared_view_different` to an Inspect-only helper. Legacy route, writers, capture, backward recovery and all metadata semantics remain unchanged.

A small recursive Type decision owns actual affine fields:

```text
Found(actual C, remaining, past)
Absent(remaining, past)
Advance(remaining, past)
Exhausted(remaining, past)
Wrapped(inner Decision)
```

The recursive variant intends Native boxed transport; it does not guarantee cheap allocation. Inspect actual emitted widths, array/C ownership and JS constructors before selecting the candidate. Wrapped decoding must preserve arbitrary depth without a gas/drop branch.

Definitions in DAG order:

1. A boolean decision helper accepts scalar id, actual C, tail and history. Equal returns Found; before returns Absent with the original node rebuilt; advance returns tail plus exactly one `HistoryCon{id,Some{actual C},past}`.
2. `step(fuel,remaining,past,target)` has one head match. Nil precedes fuel and returns Absent at every fuel. Nonempty fuel0 and fuel1 both return Exhausted with all owners retained. Fuel2+ invokes the boolean helper directly, without an intermediate handoff node or phase. Positive Nat pattern syntax `2n+rest` exists in pinned Bend examples; checker legality still requires a bounded prototype.
3. `loop(fuel,values,metadata,capacity,target,decision)` has one head match. Terminal decisions precede fuel checks. Found projects exactly once through the unchanged projected-owner helper, storing the actual returned C. Absent installs current=target/None; Exhausted installs current0/None. Advance with fuel2+rest tail-calls itself at rest and `step(rest,tail,past,target)`. Thus the loop's explicit Nat decreases by two; no separate gas is needed. Forged raw Advance at fuel0/1 returns a current0 refusal retaining every owner. Wrapped unwraps structurally at unchanged fuel.
4. A reusable Nat-fuel entry initializes both loop and step. Only Nat Data is reused; no Type owner is duplicated.

Expected source mechanism: one Decision per processed row substitutes the transient HandoffCon/Choice/Inspect sequence on the normal path. Required final state/carrier, history, Some owner and terminal retained-node constructions remain. This is a hypothesis until source-current counters/profiles and unchanged gates pass.

## Finite gates before delivery

- Compare private Inspect against the exact original indexed and legacy functions over target/fuel/remaining/history combinations, including Nil at fuel0/1, equal/before/skipped nodes, odd fuel, holes and existing history. Observe current/capacity, remaining/history order, every recovered payload cell and all stamps.
- Use a legal projection that changes returned Array payload. Found calls it exactly once and stores that actual owner; absence/refusal/skipped nodes never call it. Preserve aliases, backward recovery, growth and caller-current history insertion exactly once.
- Preserve and replay all five public explicit phase cases, including contradictory Choice fields, original function-type clients, arbitrary Type families and authority negatives.
- Reached compiling fuel-off-by-one, owner-drop and history-order mutations must fail complete observations on JS/Native. Full unchanged Workshop and transaction/refusal/fallback controls remain required.
- Five-second checker/runtime caps, emitted layout audit, source-bound before/after CPU/allocation diagnostics and unchanged paired performance gates decide acceptance. No universal raw-helper safety or new authority claim follows from this private trusted seam.
