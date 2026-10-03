# R-C1 two-schema abstract query experiment

Issue [#15](https://github.com/dearlordylord/bendvy/issues/15), parent [#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md), [R-A](../ra-provider/README.md), [T03](../t03/README.md), [R2 recipe](../../docs/reference/traces.md), [T12 checkpoint](../../docs/t12-redesign-decision.md). Base: `7cb164a00484636ed61b688e1b30d685c4c94dd9`. Date: 2026-10-03. Read GitHub #15/#14/#1 with `gh issue view --repo dearlordylord/bendvy --json title,body`, the linked documents and AGENTS.md. Applied `/home/node/.codex/skills/bend-ldd/SKILL.md`; ran `bend version` and `bend guide` before Bend work.

**Outcome: bounded experimental two-schema typed-query/R2 gate passes the recorded inputs, subject to independent coordinator verification.** This is a candidate for resuming the original dependent probes #5, #6, #10 and #12. It is not a production API/storage choice or full-core acceptance. The parent remains open.

## Inputs and public observations

Inputs were recorded in [candidate statements](CANDIDATE-LAWS.md) before implementation. No ECS proof was written.

- Motion composition: Position{x:U32} and optional empty `Tag{}` Data payload. Setup a has Position=0 and Tag; b has Position=10 without Tag. One closed `motion_step` template is executed three times, adding 1 to each Position.
- Health composition: HitPoints U32, required Damage U32, optional Armor U32. Setup a has HitPoints=20, Damage=3, Armor=1; b has HitPoints=30, Damage=2 without Armor. The same `health_step` template executes three times, subtracting the declared read-only Damage from HitPoints. Armor is observed and retained, not used in the arithmetic. These bounded inputs do not underflow.

Bend setup assigns logical labels in `schemas.bend`; the reference adapter assigns the same input labels at public spawn reservation and records returned IDs. The reference's public numeric ID value is only a key into that runtime's reservation map; labels are never guessed from ID numbers. Unknown or duplicate IDs fail normalization. Bend label lookup is an experimental substitute for identity; allocator, world-scoped durable identity, reservation and stale/foreign handles remain #6.

Each schema produces 31 ordered lines: seven setup observations; for each of three steps one in-callback writable-cell read followed by seven reader observations. Those seven are Required, Present, Absent, Optional traversals and live-b Required/Present/Optional lookup. Required includes an optional metadata read slot; its required value (and Damage in Health) determines membership. Present is Tagged/Armored; Absent is Untagged/Unarmored. Both return actual matched rows, including component values. Optional explicitly emits `present{}`/`absent` for Tag and `present=1`/`absent` for Armor. The complete freshly observed Node transcript is [observed.txt](observed.txt), checked against newly executed Node/native/JS output on every run.

| Schema | Setup | Step1 own and later reader | Step2 | Step3 | Query order / membership |
|---|---|---|---|---|---|
| Motion Position | 0,10 | 1,11 | 2,12 | 3,13 | Required/Optional [a,b]; Tagged [a]; Untagged [b] |
| Health HitPoints | 20,30 | 17,28 | 14,26 | 11,24 | Required/Optional [a,b]; Armored [a]; Unarmored [b] |

Damage remains [3,2], Armor a remains present=1 and b absent at every Health checkpoint. Live-b Required lookup matches, Present yields typed `QueryMismatch`, Optional matches with explicit absent metadata at all four checkpoints for both schemas. No query traversal is sorted or inferred from constants. Row observations are constructed by application callbacks using supplied cell getters; membership comes from the query provider. Lookup's `Matched`, `QueryMismatch`, `MissingEntity` are actual Bend datatype constructors. MissingEntity is implemented but not an acceptance observation here.

The Node-only adapter imports the pinned public core and uses public Schema/Descriptor, commands.spawn, query.each, writable update/get, optional present/get and lookup.get. Setup uses Spawn + applyDeferred + Read. Each subsequent tick uses the same Schedule(Step,Read) and contains no structural marker. Bend performs explicit setup; its equivalent sequence is writable traversal followed by read traversals/lookups before the next Step. This compares the post-setup component/query phase, not structural spawn or transaction implementation parity.

## Trusted provider and application boundary

`api.bend` and `schemas.bend` are trusted provisioning/traversal; `system.bend` contains application callbacks. All definitions and constructors are public. The experiment assumes no import restriction or secret constructor. Public symbols include Cell/Row/World, Selection and LookupResult constructors; cell_get/set, selected, restore_row/world, join_row/read_join; read_row/include/presence/decide/rows and query; write_row/rows and writable; lookup_restore/match/include/presence_rows/presence/decide/row/rows/world and lookup; both schema token constructors, Tag/TagCell/CombatData/CombatCell, concrete getters/presence helpers and setup/formatting functions. Driver printing/tick/run helpers are public too.

For schema token S and observation data D, read callbacks have this type:

```text
@-P: Type -> @-M: Type ->
(P -> S -> P & U32) -> (M -> M & D) ->
String -> P -> M -> P & (M & String)
```

Writable callbacks additionally receive `(P -> S -> U32 -> P)` and a second `(P -> S -> P & U32)` for the immediate post-write read. Supplying two fresh affine reader functions avoids duplicating a closure. D is `Maybe<&2, Tag>` for Motion and `CombatData{damage,armor}` for Health. Application callbacks check for arbitrary P/M, receive only one row's abstract handles, and return those handles beside their observation. They receive neither World nor a concrete cell/aux handle. The provider instantiates P with Cell<S> and M with TagCell/CombatCell and restores the row and world. Row lists, worlds and cells are affine Type values; only labels/observations/payloads are Data. Traversal rebuilds the affine list without copying its rows; every observation returns world ownership to the next operation.

Generic query/provisioning entry points take closed concrete getter/presence templates. Choosing these templates is trusted provisioning, not authority supplied to an application callback. The drivers choose tag_get/tag_has or combat_get/combat_has. The raw generic provider is not a production read-only world facade: a world owner can choose other concrete operations on its own storage. Calling a public provider on detached concrete storage from inside an abstract callback cannot consume or replace the callback's original P/M handles. No whole-world callback, unsafe/foreign constructor, unfilled declaration, checked-action replacement or new dependency is used.

Required/Present/Absent/Optional are four explicit selection constructors over the one optional component in each schema; the closed row composition is experimental. Lookup threads the entire owned list while locating the input label and checking selection. It is not a general schema DSL, allocator or query planner.

## Reproduce and evidence

Run `./experiments/rc1-query/run.sh`. The final verification completed with exit 0. The runner first re-executes all delivered R-A paired controls and its native/JS/actual-reference checks, then this experiment's controls, builds and comparisons. Requires the existing Bend 2.0.34, Node v24.20.0, Debian clang 14.0.6, timeout, rg and the absolute read-only reference checkouts. No dependency was installed.

The inherited R-A identity checks pin Base SHA256 `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` and check all three HEADs against [.references/sources.json](../../.references/sources.json):

- bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`
- bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`
- bend2 `a950fd683c0d76f09794078e6174fe98a1492876`

Each checker/build invocation uses [bend-check](../t01/bend-check), a five-second kill limit. Runtime/reference invocations also have five-second limits; native uses one worker and GPU off, JS uses Node. Every unexpected exit, timeout, missing verdict, unrelated diagnostic, missing/reordered checkpoint or backend divergence fails the runner. Temporary build/check logs are removed at exit. Standard output preserves the compact control ledger and all 62 raw semantic lines. A combined native entry initially exceeded five seconds; it was removed, and the two schema entry points now build independently within the unchanged limit and concatenate their output in input schema order. This is build partitioning, not a skipped observation or raised timeout. The runner measures no timing acceptance.

## Paired controls and mutant

[controls.json](controls.json) declares the exact expected/observed type and failing function for each of 28 negative fixtures; [controls.mjs](controls.mjs) requires rc=1, SOME PROOFS FAIL and those complete diagnostic lines. Every paired positive requires rc=0 and ALL PROOFS CHECK. Each schema covers:

- write-through-read at concrete setter: Cell<schema> versus abstract P;
- undeclared concrete auxiliary read: TagCell/CombatCell versus abstract M;
- foreign schema token, concrete foreign cell and foreign World substitution;
- reconstruction from a read value, public constructor + setter, fabricated World, fabricated Row and fabricated auxiliary handle;
- malformed query-return, lookup-return and writable-provider-return paths attempting to return a detached World as P;
- malformed writable callback returning a detached concrete cell instead of P.

Reconstruction positives retain the original P. Nested-provider positives actually query/lookup detached legitimate storage and return the original abstract handles. The executed schema drivers demonstrate legitimate concrete provisioning, constructor/getter/setter, query and lookup paths; write rejection does not come from rejecting all operations. The generic negative definitions intentionally model callback types directly, without a module/import ban. `A.Cell`/`A.Row` without displayed parameters are the checker's constructor diagnostics, not an unrelated syntax failure. Finite controls are not a parametricity theorem, do not rule out every Bend program and do not establish affine Type payload acceptance.

The [semantic mutant](mutant-system.bend) replaces Motion's `x+1` write with `x`, leaving Health unchanged. It checks and compiles on both backends, which agree on its 31 Motion observations. Setup still matches. [compare-mutant.mjs](compare-mutant.mjs) detects the first required own-read difference: original `motion:step1:own:a:1:present{};b:11:absent;` versus mutant `motion:step1:own:a:0:present{};b:10:absent;`. It also requires all named checkpoints to remain present and ordered. Candidate statement 2 is falsified on this mutant at the documented finite input. This is finite runtime mutation evidence, not proof failure. Ordinary ALL PROOFS CHECK wording here certifies well-typed safe definitions; no ECS law/proof exists.

## Passed, failed and inconclusive portions

**Passed:** R-A reproduction; 28 intended-type negative/positive pairs; two genuinely different component compositions; 62 exact ordered setup/update/reader/presence/absence/optional/live-lookup observations from public APIs; native/JS/actual Node-reference agreement; compiling semantic mutant detected. These results support only the bounded experimental return gate.

**Failed exploratory implementation:** the initial combined native build exceeded the mandated limit; separate builds resolve this in the delivered runner. No required checkpoint or intended control fails in the final candidate. T03's earlier constructor-only design remains failed; its negative report is not upgraded into a capability pass.

**Inconclusive/unmeasured:** universal capability confinement, model proofs, executable-function proofs, universal runtime refinement, representative performance, affine Type payloads, captured state, dynamic storage/lifecycle/identity, rollback, independent event/change readers and general schedules/provisioning. Finite query-order agreement does not establish lifecycle-order preservation. Specific laws and numerical thresholds still require approval. No approval request is necessary to execute this already authorized bounded experiment; no approval of future laws/dependencies/thresholds is inferred.

Return conditions: replace fixed two-row fixtures and closed single-optional selections with scalable sparse/dense/churn traversal and measured costs before choosing storage/API; investigate affine Type payload access/update/rollback in #5; investigate stable identity and structural barriers in #6; failure/commit/rollback in #7; readers in #8/#9; captured system state and nested provisioning in #10; equivalent representative native/JS benchmarks, memory/scaling and approved thresholds in #11; broader law falsification and approved specific laws before proofs in #12. Native substantial speedup and JS comparability remain mandatory. The [evidence/follow-up map](../../docs/follow-ups.md) retains the original full core, including relations/scopes, states and tooling. No performance or universal correctness acceptance is claimed.

No master, issue, claim/state, reference, DALPH.md, original jev/dalph or dependency changes. No Dalph-specific problem observed. Coordinator/integrator owns publication and delivery.
