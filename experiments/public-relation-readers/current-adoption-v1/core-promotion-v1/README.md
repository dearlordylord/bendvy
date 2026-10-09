# #43 core integration handoff

Apply `promotion.patch` in the root integrator's isolated checkout. It adds eight modules, changes imports only, and has passed `git apply --check` against root `4823fb32`. `PROMOTION.json` pins every original/candidate byte and confirms all referenced current core dependencies equal the qualified source. Nothing has been written into shared `src`.

| Qualified implementation | Proposed core placement |
| --- | --- |
| queue, domains, readings, routing | `src/ecs/internal/relation-failures/` (four files) |
| wider/barrier | same internal directory; actual World clock advances once per barrier |
| wider/runtime-v14 | `src/ecs/relation-failure-runtime.bend` |
| ordinary reader-declaration | `src/ecs/relation-failure-reader.bend` |
| wider/disposal-v14 | `src/ecs/relation-failure-disposal.bend` |

The ordinary declaration retains the same `G.Descriptor<S>` used by mutation; its key/name derive registration domains and diagnostic access strings. `register`, `run`, `skip`, `with_world`, `barrier`, `frame` and `dispose` retain the existing Registry, world and arbitrary Type component/resource/argument/output owners. Logs contain Data notices; this does not promote arbitrary-Type event storage from #53. Disposal removes memberships only after successful canonical `Sy.dispose`; refusal retains the runtime and reader. No new validation, capacity, activation, cleanup or error policy is proposed.

Keep fixture schemas, projections/classifiers, `Parent`/`OtherParent` authority markers, application bodies, observation DTOs, renderers, collectors and oracles in experiments. The obsolete pre-v14 runtime and per-command-clock barrier are excluded. Diagnostic access strings are not capability enforcement. The trusted provider/runtime receives World; application-facing reads must use the existing closed abstract-owner capability route. The four fixture negatives demonstrate that route, not blanket confinement of every runtime callback. Reuse core `capabilities.ValueRead` for the closed provider bridge; do not export fixture-specific Parent markers as a public schema API.

## Consuming migration

1. Root integrator applies the eight-file patch. Copy the complete ordinary consumer closure into an isolated src-consuming fixture; rewrite **every** import of the eight originals to its proposed core target and every common core import to that same checkout. This includes fixture routing/domain observers and disposal, not just the registration callsite. Keep helper imports for fixture-only modules local. The migration is import-only; record old/new hashes and regenerate strict nominal constructor inventories.
2. Preserve both schema applications, actual foreign worlds, arbitrary component/resource/private Arrays, all mixed event/removal cursors and the exact singleton full-capacity consumer. Use the existing canonical `Sy`/`W`/`Ev` route and the same `RC.Notice` classifier from #42; source-identical composition is recorded in `PROMOTION.json`.
3. Add an ordinary system provider callsite using the existing closed ValueRead bundle, so gameplay sees an abstract H and the declared relation reading operation rather than raw World. Carry the existing undeclared/cross-schema/write/owner-duplication refusals through this **actual new core callsite**. Metadata-only declaration adoption alone cannot close this authority gate. No new public read/write policy is needed.
4. Run source5 on the complete migrated application. Obtain independent source/import/type-join review and complete oracle binding before backend execution. Rebase both reached mutations at the actual promoted `run_result`/publication callsites in copied sources; frozen historical source namespaces remain unchanged.

## Evidence and remaining acceptance

| #43 requirement | Existing evidence | Still required after promotion |
| --- | --- | --- |
| Independent ordered failure/retry, skip, lag, disposal, barrier; full owners | Six ordinary JS/Native cohorts `505cb37a`, including wrong-reader and premature-publication full countermodels | Source-current core consumer and public capability/provider bridge, complete semantic controls and reached mutants |
| Foreign command MissingEntity / unchanged queue, two schemas | Complete finite/ordinary consumers and source authority negatives | Bind to promoted module identities; no independent-factory-root universality claim (#38) |
| Full 65,537 missing-target + self command / 65,536 retention per schema | Unpatched Native `ccc6f3b7`: complete singleton output 158,712,404 bytes; copied iterative JS `7e0de4a7`: identical bytes; full nested `bda9…` model | Core consuming source/current backend bindings; retain all physical queue fields and owners |
| Actual pinned TS shared reference | `f358a5f1`: all 52 observations, complete 46,244,319-byte independent `5217231a…` oracle | Explicit comparison mapping, not erased Bend physical fields or invented TS foreign/disposal API |
| Installed JS printer | Original recursive printer fails **after** full application completion (`22639b0f`); exact copied iterative printer passes | Installed output-path qualification remains open; copied-printer success is not installed-printer success. Keep it visible under #43 delivery, not a new scope reduction |
| Executable delivery/performance | No new measurement claimed | Unchanged #28 paired regression on merged core; complete feature-specific TS/JS/Native timing/scaling under #21/#23/#24; defer comparison under contention |
| Completion | Issue remains open | Independent Spec/Standards review, master integration/push and English governing-issue report before closure; #61 inventory must reflect actual public acceptance |

Raw output models differ deliberately: TS lacks Bend physical front/back queues and affine ownership evidence; its skip/window details and ordinary public unregister surface differ. Bend follows the selected canonical World clock and owned disposal contracts. Finite controls are not universal proofs. No laws, dependencies, numerical tolerances or contract choices are introduced by this handoff.
