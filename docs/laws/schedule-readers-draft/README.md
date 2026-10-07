# Schedule reader metadata law draft — unapproved

These three equations are proposed for approval, not approved contracts. `LAWS.bend` deliberately has three unresolved law obligations and contains no proof definitions. The five-second checker reports exactly three TODOs. No ECS proofs, dependencies, kernel changes, runtime contract amendments, or performance claims are introduced.

The subjects are only the pure `Data` helpers `ReaderDomains.split` and `ReaderDomains.event_batches`. The independent specification uses direct recursive selected/rejected filters and direct recursive batch filtering; it does not reuse the production accumulator loops. The classifier is a closed deterministic `E -> Bool` setup function. `True` identifies the ordinary event domain; `False` identifies the complementary domain. Whether a particular schema classifier assigns the intended gameplay meaning is outside these laws.

| Candidate | Exact proposed property | Reached compiling mutant | Literal witness |
|---|---|---|---|
| `stable_partition` | Both output lists equal their respective stable input subsequences, preserving duplicates. | Invert the classifier result in actual `split_loop`. | `[E7,R9,E2,R9,E7]` must yield `[E7,E2,E7]/[R9,R9]`. |
| `filtered_batch_order` | Filter every batch's values stably; omit exactly batches with no selected values; preserve batch order, original ticks and duplicates. | Remove the final reversal from actual `event_batches_loop`. | Ticks `9,4,9,2`, containing mixed, removal-only, empty and mixed batches, must retain batches `9:[E7,E2]`, `2:[E7,E7]` in that order. |
| `retained_publication_ticks` | The retained tick sequence equals original ticks of exactly the nonempty selected batches, in input order. | Replace the constructed retained batch's tick with zero. | The same witness must retain ticks `[9,2]`, including the original nonmonotone order. |

The third equation intentionally makes the tick obligation independently visible; it is implied by the stronger second equation. No increasing-tick assumption is required by these pure equations. They do not state how runtime cursors advance, where a retention boundary lies, when a reader is registered, or what a failure consumes.

`falsify.bend` supplies eight finite comparison rows: four partition cases and two batch cases with two observations each. Cases include empty input, one-domain input, duplicate values, U32 maximum, notice-only and empty batches, repeated ticks and nonmonotone ticks. These are finite literal observations, not exhaustive testing, model proofs, executable-function proofs or universal runtime refinement.

## Evidence

Run `python3 docs/laws/schedule-readers-draft/run.py --output <new-output-directory>`. The runner pins commands to CPU5. Checker/runtime caps are five seconds; JavaScript emission cap is thirty seconds. Native compilation is deferred during the root measurement window. The final receipt is `evidence-final/receipt.json`: PASS, 13 bounded commands, normal JavaScript observations matching all eight rows, and all three checked/emitted/running mutants disagreeing with their designated literal. Complete stdout/stderr and generated JavaScript are retained. Source hashes cover the recursive explicit Bend import closure and runner; staged and live source hashes are checked before and after commands. This small draft receipt does not claim the full reference/Base/tool inventory guards of the separate #35 semantic harness.

`evidence/receipt.json` retains the initial incomplete attempt: the tick mutant's overly broad text replacement also changed a pattern binder, so it failed checking and was not credited as a reached mutant. The final mutant replacement changes only the constructor expression; its checker and runtime both succeed. Final source subject hash is `097b77d279056d305eacda7ac35eefb499f98b7a845d306c8fe7bc411a160021`.

## Explicit limits and pending decision

Approve, revise or reject these precise metadata equations before any proof work. No runtime cursor law is proposed here. No equality of a projected `Data` view is an equality or refinement of an affine `Type` World. Actual `Events`, World, resource, registry and callback owners are outside the subjects: confinement, consumption, namespace recovery, rollback, disposal, publication synchronization, retention and barrier behavior remain source-current scoped executable controls in #35. The arbitrary affine-owner adapter and schema classifier are not universally validated by these laws.

Core and experiment executable inputs remained frozen. This draft does not upgrade the finite #35 evidence to production API approval or feature performance acceptance.
