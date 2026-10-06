# Descending private query-state reuse diagnostic

Frozen source: `b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0`, `/tmp/bendvy-private-id-query-descending-v1`. This emitted-JavaScript probe starts from the unchanged first-stage row/pool/Tuple parents, not the Fold candidate or the Slot Host source. No Bend/compiler changes, timing comparison, adoption or full22 acceptance.

| Schema | Parent SHA256 | Candidate SHA256 |
|---|---|---|
| Motion | `11a315855c9cf15cb593a92303732c457b0f82834fe6ca801a94b27e47cb1709` | `8fb4b25235ddb34c466755b88615665177146a715742a2887715d1ef3ad91beb` |
| Health | `32942fb0f0f7dbd0b1d15032a4b20bb155ee7e2e32916e44e4d63c6110a744a5` | `7d4af57d1d4959ce286ba44bcb780a5db31579c2d636bc0196b0e1917b97826d` |

## Mechanism and scope

Bend `query.bend:70` declares `StructColsState<M:Type,A:Type,F:Data,O:Data>` as affine Type. Private `read_rows` (line320) creates its fresh writable object; the iterative descending `go` (315) consumes/returns that owner; `finish_forward` (312) exposes Rows and the Data ID list, not the state wrapper. The selected path invokes only intrinsic membership inspection, not a user callback/getter. Source payloads, authority and generic APIs remain unchanged.

The exact reached emitted chain is advance → direct Tuple helper15 → original metadata → selected → inspect → restore. Helper16 is retained but not reached on this ingress. An initial enrollment hypothesis expected helper16 and failed `unique tuple bridge`; correcting this analysis changed the enrolled family, not either input program. It produced no candidate/measurement. The current catalog pins the actual six function bodies, caller, complete programs and source29/provenance files.

The recipe clones those six helpers and changes one saturated call inside the cursor loop. At five terminal publications, all seven original RHS expressions first evaluate into fresh constants, in original order. Only afterward do plain writable state fields receive the results, followed by returning that state. Every original array read/set, opaque Main transport, Some/None branch and Data-list constructor remains. Main/Aux owners are not cloned or restricted to Data. Data tails and cached snapshots are never assigned. All original functions except the single loop call remain byte-identical, including generic callbacks, optional/present/absent paths and fallback functions.

The owner cannot escape between its allocation and loop return on this pinned call edge: helpers only decompose/move columns, and the loop's state argument is consumed once per iteration. No identity observers, proxies, getters, reflection or FFI occur in this private chain. This is a closed-program transport argument, not a universal JavaScript alias theorem. Unknown programs, body changes and reflective constructs are refused. Original RHS exceptions/side effects precede field stores; the additional stores are plain own writable-property operations on the fresh compiler record. Arbitrary exported helper calls with externally aliased/frozen state are outside admission.

## Fresh finite evidence

CPU10, each child supervised at five seconds. No comparative clocks were analyzed.

- Both parent and candidate: 65 complete Motion and Health checkpoints against separately executed TypeScript reference (`full65.py`).
- Nine complete worlds/schema and instrumented phase counts: Motion ordinary constructors 5,241,920 → 5,110,848; Health 4,982,336 → 4,851,264. Exactly StructColsState 131,584 → 512 (−131,072). All other constructor-kind totals unchanged. This is ordinary constructor execution, not exact physical heap bytes or a speed result.
- Twenty-six independent authored retained/selection/order records per schema: lengths1/2/4/8, Required/Present/Absent, two namespaces, missing/dead membership and invalid capacity. Every raw/cache field and old frozen Data snapshot/list tail is preserved; Main/Aux/metadata column and opaque Main references remain identical.
- Four parser-valid, executed counterexamples detected: omit selected-ID publication or omit true owned Main restoration, separately per schema.
- Eight structural/reflection refusals and byte-level preservation of 532 original Motion function bodies; one changed caller and six new helpers. Finite and structural checks do not establish universal affine refinement.

## Open transaction ingress gate

All eight actual protected cached/raw/normal/suppressed controller inputs contain **zero** cursor advance/go definitions: they take supplied IDs. Each strict recipe admission was actually attempted and refused `unknown input`, with no output artifact. Their unchanged 576 records were freshly replayed against the original independent and suppression oracles, explicitly labeled **UNREACHED preservation**, not candidate coverage. No passing Tx gate transfers to this probe. Meaningful coverage needs fresh source-exact fixture query ingress and unchanged full72-checkpoint transaction oracles, followed by emitted-pipeline enrollment and reached-call witnesses. The original source29, recipe guards and normative oracles were not relaxed to manufacture coverage.

Generic nonidentity getter/fallback runtime coverage remains open for the generated chain; those original bodies are byte-preserved, and private cursor inspection has no arbitrary getter parameter. This package is a prospective diagnostic, not selectable/adoptable acceptance.

## Replay and receipts

`input-pins.json` lists complete inputs,29 source pins and39 provenance files/schema. `enroll.cjs` requires the exact upstream catalog and verifies every existing provenance hash; `rewrite.cjs INPUT FRESH_OUTPUT` checks them again. Use `node --expose-internals` (Node24.20.0 internal Acorn; no dependency installation).

Run `full65.py --output FRESH`, `count-controls.py --output FRESH`, `witness-run.py --output FRESH`, `mutants.py --output FRESH`, and `controller-admission.py --output FRESH`. Witness/mutation scripts reference the frozen candidate paths recorded above. Structural controls: `node --expose-internals guard-controls.cjs PARENT CANDIDATE FRESH_DIRECTORY`.

`evidence/index.json` maps203 exact source/input/program/command/output files to153 deduplicated byte objects in `evidence/objects.tar.gz`, including both earlier and strengthened witness/mutant runs. `verify-evidence.py` validates every object and archive hash without execution or writing absolute paths. Runtime receipts retain actual argv, five-second caps, exit codes and output hashes. The initial enrollment analysis error above is a recorded reconstruction of terminal tool output, not a fabricated subprocess receipt. No source proof, Native effect or performance acceptance is claimed.
