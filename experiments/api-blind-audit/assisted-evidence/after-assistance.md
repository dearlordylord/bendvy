# After coordinator language assistance

This is an assisted follow-up, not a rewritten blind report. The coordinator supplied one language correction: change observer binders `-P/-U/-get/-ag` to `~P/~U/~get/~ag`, matching the template callback provider contract. No implementation or optimization history was disclosed. The original report, impressions, clients and diagnostics are byte unchanged; `frozen-before-assistance-manifest.json` captures their hashes before the new work.

**Correction:** the blind report's payload-query blocker was a client binder mistake. Generic payload-reading query is now **Pass for these finite examples**, including an affine owned Array payload. The closed system registrar and two-Type-slot schema findings remain unchanged; separately registered movement/damage and the requested full application remain unsupported by the supplied interface.

## New receipts

All commands/exit codes are in `after-assistance-commands.tsv`. Run `consumer/check-after-assistance.sh` to reproduce. No timeout, repair, new dependency, library edit, raw storage mutation, private authority fabrication or copied gameplay was used.

| New fixture | Command limit / result | Meaning |
|---|---|---|
| `template-query.bend` | check5s, exit0, `[3]` | Only observer's four binders changed from frozen minimal.bend; actual custom affine Position payload read |
| `template-query.mjs` + `run-template-query.mjs` | emit30s exit0, Node5s exit0, Con{head:3,tail:Nil} | Compiled payload-reading query with exact output assertion |
| `template-array-query.bend` | check5s exit0, `[3]` | Actual library T.Position Type with owned four-slot Array; Raw.position_get adapter reads first observed coordinate; callback remains abstract |
| `public-setter-control.bend` | check5s exit0, PositionView{Four{9,3,3,3},0} | Actual exported Raw.position_swap accepts concrete owned T.Position, updates coordinate, then Raw.position_get observes it |
| `template-public-setter-negative.bend` | check5s exit1, expected T.Position / observed observer~P | Same public setter attempted on opaque read callback owner; intended concrete-versus-abstract rejection |

Array construction here creates the component payload itself (`T.Position{[3 : U32^2n],0}`), not an application-side storage column or alias. All storage remains inside public create/reserve/barrier/query operations. The small adapter converts the library's public PositionView to the scalar observation; it is not a new engine or schema generator.

The old getter extra-arity and token controls establish callback shape/type restrictions only. They never demonstrated actual public setter confinement. The new setter pair does establish that the tested exported concrete payload setter cannot consume this query callback's abstract read owner, with a passing actual setter control. This is a bounded type-check observation, not a universal access/authority proof. Constructor forging, arbitrary malformed worlds and other exported trusted adapters are outside this pair's claim.

## Source citations and interpretation

- [Bend template guide](../bend-guide.txt#L257), lines 257–274: templates receive syntax, inline at compile time, and use closed leading `~` arguments. This was enough to correct the client after assistance; the initial `-` interpretation was wrong.
- [Generic query provider contract](../library/query.bend#L29), line 29 and line 119: abstract P/U and getter providers in the dependent callback, restored owner pair, public each entry point. [template-query.bend](../consumer/template-query.bend#L35) supplies `~` binders rather than ordinary erased live parameters.
- [Public payload setter](../library/payload.bend#L28), lines 22–30: position_get and position_swap consume/return concrete T.Position. The negative fails specifically at the owner argument, not at excess arity, missing setter symbol, import, unrelated error or timeout.
- [World shape](../library/storage.bend#L82), lines 82–84: two Type payload slots M/A plus Data flag F, ledger and mode. [Schedule registrar](../library/schedule.bend#L6), lines 6–23 and 43–47: closed BodyKind and registration taking kind. Those findings do not depend on the corrected getter syntax.
- Rust primary reference: `/workspace/formal-proofs/bendvy/.references/bevy/examples/ecs/contiguous_query.rs:26` defines health-decay user function; `:39` defines command/despawn function; `:52` registers functions. `/workspace/formal-proofs/bendvy/.references/bevy/crates/bevy_ecs/src/system/query.rs:679` returns ReadOnly iteration; `:717` offers mutable iteration. `/workspace/formal-proofs/bendvy/.references/bevy/crates/bevy_ecs/src/schedule/executor/mod.rs:159` defines ApplyDeferred.
- bevy-ts primary reference: `/workspace/formal-proofs/bendvy/.references/bevy-ts/examples/concepts.ts:25` binds component schema; `:36` defines read/write query; `:40` registers authored movement callback; `:52` defers spawn; `:101` declares explicit deferred setup boundary. `/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/System.ts:1043` takes SystemRun callback.
- Bend checker primary reference: `/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts:3210` describes live/dead demand and affine accounting; `:3478` implements duplicate-owner rejection. These ownership requirements remain real even though the query itself now works.

Source commits remain Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60, bevy-ts 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334, Bend a950fd683c0d76f09794078e6174fe98a1492876. No performance acceptance, model/executable proofs or universal refinement is claimed.
