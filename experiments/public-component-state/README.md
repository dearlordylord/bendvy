# Component-state experiment (#47)

Experiment only. No production contract, law or proof is approved here.

Run the first stage with `python3 experiments/public-component-state/reference-run.py`.
It needs the existing Node runtime and pinned absolute references; no packages.
The runner refuses an existing output directory and records source hashes, clean
reference HEADs, the manifest, capped commands and all observations. It performs
no comparative measurement or native build.

## Observed reference coverage

Source-current receipt: `.artifacts/component-state-reference-1791355180539136992/receipt.json`
(54 JSON observations; Node v24.20.0).

| Subject | Observation | Coverage limit |
| --- | --- | --- |
| Defaults | No implicit constructor default: `undefined` fails for string and numeric state | Ordinary typed spawn always takes explicit values |
| Legal values | All three string states and three numeric states accepted | Two finite vocabularies |
| Invalid construction | Unknown value, wrong kind, null and undefined reject | Public constructor, not hostile typed-value cast validation |
| Matching | Required Phase+Mode query excludes the neighbor-only entity | Presence selection; no dedicated state-value filter was identified |
| Deferred lifecycle | Spawn is invisible before barrier, visible after | Actual runtime schedule |
| Compare-and-set | Legal move succeeds; stale expected value returns StateMismatch | Graph with three states |
| Graph | JS can bypass pair restrictions and perform ready→active | Graph restriction is TypeScript static typing, not runtime graph checking |
| No graph | Numeric 0→2 succeeds | All nine pairs observed |
| Transaction | Failed registered system rolls back both state components | Array neighbor remains complete |
| Change reader | Initial added state appears, failed write does not appear; successful transition appears once | One registered tracked watcher with independent Phase and Mode queries in each schema |
| Replacement | setRaw legal replacement succeeds; invalid replacement retains old state | Same-value typed set triggers changed reader |
| Snapshot | Invalid state rejects without mutation; legal constructed-neighbor snapshot restores | Plain unvalidated descriptor instead fails UnvalidatedDescriptor |
| Schema/world ownership | Two nominal schemas checker-pass; independently created same-schema worlds checker-pass; execution pending | TS foreign numeric collision observed separately; existing approved Bend MissingEntity divergence applies |
| Access controls and mutation | Six intended checker rejections observed | Reached JS/Native semantic mutant still required |
| Bend execution | Pending | First frozen62-extension cohort pending; earlier38-row cohort passed JS/Native |

## Experimental adapter boundaries (public contract unresolved)

The reusable adapter accepts consumer-defined Data value/equality and legal move/endpoint types. The fixture uses a closed Data enum for each state's legal values and a separate closed move
sum for the allowed graph edges. No first-value default will be invented.
Compare-and-set returns expected/actual mismatch while preserving the abstract
query owner and leaving stamps unchanged. Successful transitions use public
Cap.set so existing public transaction and lifecycle behavior applies.
No global machine or arbitrary runtime transition graph is implied by this slice.
Arbitrary Array-bearing neighboring families must survive full observations.

## Harness preflight

Before executing the Bend pipeline, stage and hash only recursively reachable
project sources, fixtures, verifier, oracle and negative files. Check original and
staged hashes before/after each stage; retain Node/reference HEAD and source guards.
Checker 5 seconds, emit 30 seconds, approved Clang19 compile 120 seconds, runtimes
5 seconds. Compile and execute the semantic mutant on both backends. Match each
negative's intended expected/observed type and source location; parse/setup errors
are failures. No timings during user CPU contention. Parent integration owns the
unchanged #28 regression gate if a later core implementation is approved.

## Current review stage

Run `python3 experiments/public-component-state/run.py --preflight` for source-bound
Node and checker controls only. Full execution omits `--preflight`; native execution
uses the approved Clang19 and `--threads 1 --gpu off`. The copied reviewed owned-
descendant supervisor and tool snapshot helper are source-pinned in this directory.
The complete descriptor/application golden observations are replay fixtures, not
independent universal proofs. The first frozen38-row backend cohort passed; extended final acceptance is tracked separately in the completion report.

## Extended final freeze

The application now has 62 complete observations: both Phase and Mode change
queries, successful and rejected string/numeric raw constructions, failed-write
rollback and same-value writes in both schemas. Caller-defined raw decoders accept
String or U32; wrong raw kinds reject statically. This is a typed raw boundary,
not arbitrary JSON/unknown decoding or exact upstream DecodeError reconstruction.
Three constructor rows exercise every legal fixture value and all four graph
edges; six foreign rows include the recovered affine Array and both worlds.
Seven negative controls bind their intended types and locations.
The endpoints/equality/raw-decoder definitions remain trusted consumer declarations;
no theorem that they encode an author's intended graph is claimed.

## Checked raw write boundary (current source)

`set_raw_result` accepts an abstract `Cap.Request` returning an explicit
`WriteStatus`; it retains decoder failure separately from actual write failure.
The closed provider executes public `Cap.set` and inspects the actual returned
`Frame.error`. A prior transaction error refuses another write. No component-read
prerequisite is introduced: a live absent family remains a legal upsert.
`TypedRawWritten` means this local write was accepted; it does not commit the
surrounding transaction. The closed runner still finishes the transaction.

`raw-boundary.bend` bypasses Required-query filtering deliberately and observes
valid live writes, valid absent-family upserts, and foreign-handle write refusal.
The refusal retains `raw=active`, exact `MissingEntity`, transaction rollback, and
complete arrays/state in both independently created worlds. Five frozen expected
rows describe Bend's already approved namespace policy, not TS foreign-ID parity.
The status-omission mutant must reach `foreign|Written|transaction=MissingEntity`
on each backend. New guarded evidence is required; earlier receipts do not qualify
these additions. Current imported #46 closure includes `typed.bend` and `utf16.bend`.

## Public generic state operations (promotion candidate)

The executable consumers now import `src/ecs/state.bend`; the historical
`adapter.bend` is excluded from the promoted surface. Public `compare_set` and
`transition` take a read capability plus a checked write request. Their generic
`Outcome<Value,WriteError>` distinguishes moved, mismatch, exact component access
refusal, and exact write refusal. `set_raw_result` additionally distinguishes the
caller's decode error from write error and retains original raw input on either
refusal. The public module imports no experimental decoder/schema modules.

Consumers provide their own Data vocabulary, equality, closed typed move/endpoints,
Raw type and Result decoder. `state.bend` and `gameplay.bend` are minimal compiled
usage examples; `query.bend` is the closed declaration boundary supplying real
Frame write status. The abstract callback cannot inspect or specialize its owner.
Neither equality/endpoints/decoder correctness nor a malicious provider's status
is proved. `StateMoved` and `TypedRawWritten` mean local acceptance, never commit.

`clock-controls.bend` uses a trusted administrative clock fixture at U32 maximum,
then executes the actual public component write through the checked request.
A Found read followed by capacity refusal returns StateWriteRejected with exact
CapacityExceeded, rolls back, and preserves clock, stamps, state and full arrays.
It also reaches absent/foreign access refusal; an eighth intended negative rejects
using a read capability as a checked write request. A fourth compiling mutant
must claim Moved despite the observed CapacityExceeded transaction.
Earlier 68-command evidence remains historical after this promotion candidate.
Root owns independent review, default regression and equivalent feature timing
before production delivery.

## Exact #47 incorrect-state mutation gate

The fresh cohort adds a fifth compiling mutant in public `State.apply`: after a
successful equality check it writes `expected` instead of `target`. The complete
registered application must reach `advanced|[[0,0,[11,22,33,44]],...` rather than
Phase=Windup (1), Mode=Two (2), while still reporting a locally accepted write. JS and Native
must both execute that incorrect-state checkpoint. The preceding 81-command
receipt remains historical for this acceptance gate; diagnostic/status mutants
alone do not satisfy the issue's incorrect-state or missing-stamp requirement.


The first wrong-target cohort failed its authored checkpoint after JS execution:
this generic mutation also changes Mode, so the correct predicted mutant tuple
is Phase0/Mode0. It compiled Native but did not execute the Native mutant before
that assertion failed; no Native credit is inferred. The source-bound failure is
retained at `.artifacts/component-state-1791361208515606734/receipt.json`.

`run.py --wrong-target-only` performs the isolated corrective control. It binds the
historical public81 receipt, every portable log, identical full tested Bend/TS/
fixture/helper inventories, tools, configs and reference inventories/HEADs; only
harness/report differences are disclosed. Historical complete normal JS/Native
outputs must match fresh actual Node/goldens. It checks/emits/builds/executes only
the fresh wrong-target mutant and requires the complete wrong checkpoint twice
(two nominal schemas), on both backends. It labels aggregation separately from a
fresh full cohort. Run preflight with `--preflight --wrong-target-only --cpu 5`.
