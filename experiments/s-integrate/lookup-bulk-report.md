# S-INTEGRATE lookup traversal prerequisite

At baseline commit `ace04c2`, actual `query.lookup` recursively rebuilt all rows.
The 65,537-live-row fixture passed on Native but both JavaScript schema lanes
exited 1 with `bend: memory fault (machine stack overflow?)`. Five-row controls
passed both backends. `lookup-bulk-baseline.json` records the source/fixture hashes
and independent reproduction, without treating that failure as a semantic mutant.

The repair changes only the internal lookup traversal block in `query.bend`.
A structurally decreasing tail scan moves unmatched actual Type rows into a
reversed affine prefix, stops at the unique-ID match, reads and returns the actual
owner, then rejoins the prefix and untouched suffix. Missing reverses the complete
prefix. Public lookup, namespace validation, access classification and rank-2
provider signatures are unchanged. No `read_rows` or observation traversal change
is included in this patch.

The existing SI-Q-LOOKUP variant/domain was written in `LOOKUP-BULK-DRAFT.md`;
442 perturbed complete lookup observations were rejected before implementation.
These independent Data oracle controls are not runtime executions or proofs.

Reproduce from the repository root:

```sh
python3 experiments/s-integrate/lookup-bulk-oracle.py
python3 experiments/s-integrate/lookup-bulk-run.py --baseline
python3 experiments/s-integrate/lookup-bulk-run.py
```

The actual fixture receives schema/count through runtime arguments. One threaded
factory creates two same-schema worlds. Actual reservation and apply build all
payloads; no test synthesizes an authority handle. A genuinely reserved spare is
despawned to produce the absent handle; the second world's reservation provides a
colliding foreign handle. The fixture checks first/middle/last full-field results,
repeated returned-owner lookup, Flag mismatch, stale/foreign Missing, two Aux-only
Mismatch results after Main removal, and restored readability after reinsertion.
Before and after the chain it checks every retained row's ascending ID, marks,
full nominal Main/Aux four-slot arrays and metadata, Flag, complete Ledger, Mode,
allocator and empty queue, while threading the actual owners onward.

Both schemas pass at counts 5 and 65,537 on Native and JavaScript. Recorded largest
whole-fixture wall times (including startup and all checks) are Motion 0.122 s
Native / 0.537 s JS and Health 0.055 s Native / 0.481 s JS. These single cold runs
are diagnostic evidence, not a comparative performance benchmark or numerical
acceptance. Baseline reproduction was also running during this verification.

Seven fresh checks at actual `query.lookup` reject writes through read, undeclared
Aux access, wrong tokens, reconstructed/missing/consumed owners and cross-schema
handles, each with the expected diagnostic and a checked positive companion.
Five runtime mutants compile and differ on both backends: live Mismatch changed
to Missing, dropped prefix owners, reversed prefix order, foreign collision
accepted as local and erased retained marks.

Each checker/runtime invocation is capped at five seconds; code generation and
clang have separate 30/120-second limits. Exact hashes, outputs, diagnostics and
timings are in `lookup-bulk-evidence.json`. General root authority, malformed or
duplicate-ID worlds, arbitrary Type restoration, E11 reader retention, integrated
performance acceptance and universal refinement remain outside this prerequisite.
