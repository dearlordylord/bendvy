# Integrated core review

Incremental delivery under #35/#38/#47; these issues are not closed by this batch.

Independent Spec/Standards review found no code blocker in the World tail-scan
patch. Descending slot traversal plus prepending produces ascending handles;
two phases per slot consume exactly twice `highWater` fuel. Public `handles`
supplies that fuel. Internal helpers remain trusted implementation operations;
calling the fuel loop directly with insufficient fuel can return a partial list.
World Store, Resource, liveness and queued affine closures are threaded back.
The separate 53-command source-bound JS/Native controls include concrete pending
payloads/resources and four reached defects. They are not closure-equality proofs.

Root inspected the event/runtime changes: size counts actual batch elements
without constructing the concatenated list, append's two empty cases preserve
the other list, and nonempty append retains the original implementation.
Reader collection reuses one duplicable Data result without duplicating World.
Finite original/candidate comparisons, actual mutants and full reader controls
pass; current integrated reader observations also pass two fresh lifecycles.
Before/after CPU and collected-allocation profiles are retained; sampled bytes
are not physical memory. Current integrated feature timing/profiles remain
separate observations, not the protected baseline regression decision.

Independent #47 review resolves the earlier missing incorrect-state mutant.
The integrated 87-command receipt is `PASS_FINITE_SLICE`, SHA256
`f3722bd993d59629ef637a28939335b7382b8900a162fc5aad020e1be2c2bfcf`.
Five reached mutants execute on both backends. Wrong-target writes leave Phase
and Mode at zero in both nominal schemas; eight intended type/access negatives
also pass. No Spec or documented Standards blocker remains for incremental
module delivery. Exact checked-write status and raw/access errors are preserved;
trusted consumer equality/endpoints/decoder/provider remain outside universal
claims. Full feature timing is still required before #47 closure.

The unchanged paired #28 gate passes for all 33 current core modules plus five
benchmark inputs. Its receipt, full execution archive and actual measurements
are in `docs/reports/core-integrated-regression.md`. No baseline/workload/statistics,
compiler/runtime/kernel, dependency, numerical tolerance or approved law changed.
No ECS proof or full parity/performance acceptance is claimed.
