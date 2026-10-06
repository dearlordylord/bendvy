# V8 selective reuse: exact compatibility refusal

The unchanged selective Fold recipe rejects both current v8 first-stage programs. No optimized candidate was implemented. Root deferred a new guard derivation so the remaining window could preserve and broaden the verified v8 source result.

The exact source is `/tmp/bendvy-slot-host-handoff-v8-coherent`, closure `4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235`. The inputs are `/tmp/bendvy-source-handoff-generated-v8/motion-tuple.js` (`50eabb3c…`) and `health-tuple.js` (`dad6d67d…`). `pins.json` binds all29 actual source hashes through completed build receipts, source/cache manifests, each row/pool/Tuple intermediate and receipt, and current pipeline recipe/catalog/facts files. No consumed v8 normal file or the root's 742-pin cohort was changed.

## Observed graph and refusal

Both schemas have this exact named call graph:

```
ready → drain → __direct_tuple_helper_15 → returned
                              original taken → returned
```

The old recipe expects `step → guard → live → taken → returned`, with exactly one incoming saturated call per member. The only mismatching member of that old five-function frontier is `returned`: it has both the original `taken` caller and the scalar bridge caller. The bridge has one caller, the new drain, with18 arguments; both return calls have14 arguments. The copied old recipe and transport module are byte-identical to their originals. Fresh structural catalogs pin current bodies without changing either guard. Both executable trials fail with `Error: unknown incoming edge`; neither writes an output or output receipt.

The hot drain contains zero `array_rmw` calls. It passes the already evacuated owner as `Some(owner)` to the scalar bridge. Re-enrolling positioned swap at the old live boundary therefore does not establish a saving on the new hot boundary. This does not assess every other possible swap edge in the program.

`run.py --output /tmp/fresh-output` reproduces the exact graph and refusal on CPU7. Every Node command is bounded to five seconds. `analyze.cjs` only reads ASTs and emits graph evidence. The compatibility catalog is explicitly **not** an accepted optimized-input provenance enrollment. Original source, compiler, runtime, Native artifacts and authored callback bodies remain unchanged.

## Deferred narrower design

The reviewer conditionally proposed an explicit new bridge/drain certificate; a broad second-caller whitelist was refused. A narrower future implementation could clone only the hot bridge and `returned`, redirect only the drain's `Con`/`LedgerSome` call, and pass the original affine Fold explicitly. The old step/live/taken family and LedgerNone recovery would remain unchanged. This narrower proposal was not implemented or finally reviewed here.

Before such a rewrite can be admitted, a new guard must establish all of the following:

- Exact fresh affine Fold producer, source type and17 ordered fields; exact ready/drain/bridge/return bodies and complete incoming references, with no capture, reflection, accessor, escape or substituted owner.
- Drain ownership through both loop assignments in original order (`$0 = rest`, then `$1 = result`), Nil return and complete LedgerNone recovery. It must not assume arbitrary clients are identity functions.
- Named argument provenance from the actual drain field projections through the scalar bridge and returned function. The expected ten stable fields are namespace, next, aux, capacity, depth, high, pending, mode, commands and pings. This expectation is a design prediction, not a new verified v8 transport certificate.
- All17 original return-field expressions evaluated once, in original order, before the seven owner stores. In particular, original column publication occurs during the columns expression; pending-flush and total failures must leave the old Fold ledger unchanged. Immutable cached Data snapshots must never be mutated.
- Fresh both-schema full65 and nine-world expression counters; the actual eight retained lifecycle subjects (64 literal records), scoped bridge/terminal execution counters, full-array and true-old checks, exception boundaries including a rich actual pending-flush throw, mandatory compiling early-publication/omitted-store mutants, and guard refusals. Old130/576 or v7 controls cannot be transferred.

The only predicted construction change at this boundary is one Fold expression per successful callback, traded for seven stores. Neither physical allocation nor elapsed benefit follows from that prediction. Existing earlier selective measurements were mixed. No timing, adoption, canonical-cap reset, full capability completion or universal alias/refinement claim is made here.

## Evidence

`evidence/evidence.tar.gz` contains the small reproducible refusal catalogs, graph reports and execution logs. `evidence/manifest.json` hashes every decoded member; source/compiler/reference/binary bytes are not copied. `status.json` pins the final receipt and owned recipes. Root's independent v8 performance observations belong to their separate package and are not this probe's acceptance.
