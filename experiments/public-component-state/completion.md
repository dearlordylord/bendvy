# #47 experimental component-state slice

**Issue incomplete; public generic module finite slice verified.** This delivers typed
consumer-defined state operations over existing public ECS queries and transactions,
using `src/ecs/state.bend`. Production delivery still requires root regression,
feature measurement and final integration review.

The reusable [public module](../../src/ecs/state.bend) accepts a Data value vocabulary, equality,
legal-move type/endpoints, separate read and checked write request, and typed raw
decoder. The historical adapter is outside the promoted surface. [Fixture declarations](state.bend)
use independent string-valued Phase and numeric Mode vocabularies. Closed move
constructors encode allowed graph edges; runtime compare-and-set checks the current
value. Equality, endpoints and decoders remain trusted consumer declarations.

## Verified acceptance subjects

| #47 subject | Source-current evidence | Boundary |
| --- | --- | --- |
| Defaults, construction, legal/invalid values, matching | 54 actual pinned TS descriptor/runtime observations; three TS/JS/Native constructor rows | No implicit default; typed String/U32 decoding, not arbitrary unknown JSON |
| Heterogeneous public query/state updates | 62 complete equivalent TS/JS/Native application rows across two nominal schemas | Two state families and complete four-cell Array neighbor owners in both populated and neighbor-only entities |
| Deferred barrier and failed write | Public command spawn/barrier; registered writer fails after modifying both states; both tracked changed queries empty afterward | Finite trace; not universal rollback refinement |
| Change readers and replacement | Independent Phase/Mode changed queries sharing one registered watcher cursor; legal raw replacements, invalid raw preservation, stale transition and same-value write | Same-value writes create a change; rejected raw values and stale expected states do not |
| Access/ownership rejection | Eight exact intended type/location diagnostics: illegal state, illegal edge, raw kind, undeclared family, duplicated abstract owner, write through read, read-as-checked-request and cross-schema world | Positive closed application uses the same capabilities and two actual schemas |
| Foreign handles | Six JS/Native rows: lookup and state/Array replacement refuse, incoming owner recovered, both worlds fully observed | Two worlds created successively through one owned Factory; existing approved Bend MissingEntity divergence from TS numeric-ID collision |
| Exact runtime refusals | Five access rows preserve ComponentAbsent versus MissingEntity; five raw boundary rows accept live absent-family upsert and preserve foreign write refusal/raw input | Closed provider reports actual Frame.error after public Cap.set; local acceptance is not transaction commit |
| Exact caller decode errors | Invalid Phase/Mode raw inputs retain path, expected, actual and independently returned supplied input in the registered application | Caller-defined finite scalar decoders use #46 Error algebra; no claimed execution of generic Codec |
| Clock exhaustion | Seven rows observe successful Found read followed by exact StateWriteRejected CapacityExceeded, transaction rollback and retained maximum clock, stamps, values and full arrays | Administrative clock setup only; actual public write refusal, no new limit policy |
| Reached defects | Five compiling mutants omit decoder expected detail, coalesce MissingEntity into ComponentAbsent, claim RawWritten despite rejected transaction, claim StateMoved despite clock rejection, or write expected instead of target | Each intended incorrect checkpoint reached on both JS and Native; finite falsification, no proof/law approval |

## Evidence and replay

Run `python3 experiments/public-component-state/run.py --preflight` for the Node/checker
stage, or omit `--preflight` for the complete bounded pipeline. Use a fresh `--output`
directory if selecting one explicitly. No dependencies are installed.

Final integrated public-module receipt:
`.artifacts/component-state-1791361960587288257/receipt.json`,
status `PASS_FINITE_SLICE`, 87 capped commands. The portable receipt and all exact
command logs are retained in [integrated evidence](evidence-integrated/receipt.json.gz).
Decompressed receipt SHA256:
`f3722bd993d59629ef637a28939335b7382b8900a162fc5aad020e1be2c2bfcf`.
Public module SHA256:
`301fc0aea3ecfd95b1253fe48f51b3a11e23345bfc0bb449b3287ddbc997f694`.
All reachable Bend inputs were independently checked current after terminal.
CPU10; this fresh full cohort binds the integrated World changes and replaces
historical aggregate evidence for current acceptance. Five compiling mutants
reached intended incorrect results on both JS and Native, including the complete
wrong-state Phase0/Mode0 advanced checkpoint in both nominal schemas.

Historical public81 normal evidence and [isolated wrong-state evidence](evidence-wrong-target/receipt.json.gz)
remain separately retained. The first wrong-state cohort's oracle wrongly predicted
Mode2 even though the generic mutation changed both state targets; it stopped after
JS, and its compiled-but-unexecuted Native mutant was never credited. Its full
[failure evidence](evidence-failed-wrong-target/receipt.json.gz) is retained. The
corrected isolated control matched exact historical executable subjects; after
integration changed World, the complete87 fresh cohort above was required.

Earlier 38/62/68/81-command cohorts remain historical. One intermediate preflight
correctly failed documentation drift and received no backend credit. Final inputs
were immutable through terminal; this report and portable evidence were added afterward.

The runner binds exact reachable source/staged/mutant inventories, generated code
and executables, command logs, installed Bend/Base/effects, resolved tools and ELF
libraries, Clang resources, configuration/package inputs, prospective absence and
all three reference HEADs. The owned-descendant supervisor bounds cleanup. Limits:
checker 5s, emit 30s, Clang 120s, runtime 5s. CPU10; Native `--threads 1 --gpu off`.
Bend2.0.35, Node24.20.0, approved separate Clang19.1.7; exact tools are in the receipt.

References: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`, Rust Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend2
`a950fd683c0d76f09794078e6174fe98a1492876`. Rust ECS explicitly supports enum
components (`crates/bevy_ecs/src/component/mod.rs`); Bevy global `State<S>` is instead
a Resource with scheduled transitions (`crates/bevy_state/src/state/resources.rs`).
Bend guide/Base supply the affine Array ownership boundary used here.

## Remaining #47 gates

- **Production delivery pending:** public generic module and actual provider/consumer
  wiring are implemented and finite-replayed. Root still owns independent final
  review, unchanged #28 regression and equivalent feature timing before delivery.
  General unknown-input decoding and diagnostic host serialization remain #46's
  obligations. Exact caller decoder/write errors are implemented; discarding them
  is not an unresolved policy choice. See [promotion plan](promotion-plan.md).
  Legacy attempted/Maybe raw helpers are excluded from the public module. Trusted
  equality/endpoints/decoder/provider correctness remains outside finite coverage.
- **Laws unapproved:** [specific candidates](law-candidates.md) remain discussion
  drafts. The current five diagnostic/status/state defects and historical endpoint defect are executed; no ECS proof or universal graph,
  ownership/refinement claim is made.
- **Performance untested:** no timings/profiles were collected during user CPU
  contention. Existing #28 workload/baseline was not changed; its unchanged gate is
  required before eventual executable core delivery. Full-core/feature qualification
  remains under #21/#23/#24 and #47.
- **Final integration review pending:** parent owns independent review, any production
  adoption, commit/push and the governing-issue report/closure. This experiment is
  not grounds to close #47.
