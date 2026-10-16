## Parent

#1 — full Bend-native bevy-ts core parity.

Remaining-core specification: #37.

## What to build

Applications construct components/resources from typed raw input and receive exact failures before invalid values or partial work enter the world.

## Acceptance criteria

- [x] Inventory pinned constructed/plain/transient descriptors and Decode primitives/combinators, including struct/array/literal/nullable/handle and nested error paths; observe constructor precedence and typed errors.
- [x] Implement equivalent public typed raw-input algebra appropriate to Bend rather than an unchecked JS unknown escape. Test two schemas, malformed nested values and handle namespaces through spawn/insert/resource use.
- [x] Preserve incoming affine values and complete world/queue on rejection. Transient markers retain their distinct save semantics; no new validator package is assumed.
- [x] Detect a reached skipped-validator/partial-write mutant. Standard Schema adapters and JavaScript host bridges are archived TypeScript tooling scope, outside native acceptance unless separately approved; they are not an unresolved #46 semantic requirement.

## Blocked by

None (can start immediately; explicit unresolved contract gates still apply).

## Delivery and evidence

- Apply the [SPEC reference order](../SPEC.md#implementation-decisions): Rust Bevy architecture and ECS semantics first; Bend types, affine ownership and runtime constraints second; bevy-ts feature inventory and porting inspiration third. Record exact reference commits. Execute bevy-ts comparisons for shared agreed scenarios, not as a blanket behavior authority; preserve approved contracts and record reference differences explicitly.
- Verify through independently authored public application operations, complete JS/Native observations and an actually executed Node TS reference. Test two nominal schemas where composition/authority is extended, and actual independently created same-schema worlds for foreign-handle operations. Preserve arbitrary component families and affine Type payloads; reject undeclared access, cross-schema misuse, writes through read and owner duplication at their actual boundary.
- Freeze exact sources and retain command/input/output receipts, intended negative diagnostics and at least one reached compiling semantic mutant. Earlier task evidence does not substitute for this task's source-current acceptance. Finite traces are not universal proofs/refinement.
- Run the unchanged default #28 paired regression gate before delivering executable core changes. Keep its workload/baseline/statistics unchanged. Add equivalent complete feature-specific TS/JS/Native correctness observations without dropping work; keep boundary and capacity correctness checks. Comparative timing/scaling is qualified on the combined feature workload under #21/#23/#24 and is not a prerequisite for individual semantic delivery. Consequential hot-path changes and detected regressions still require targeted performance investigation. Final JS <= TS and Native <= 0.5 * TS goals remain unchanged. No new numerical tolerance or baseline is approved by this ticket. During CPU contention defer comparative measurements, not semantics investigation; a timeout is inconclusive.
- Use before/after JS call and allocation profiles for a consequential performance change; report allocation sampling separately from physical/RSS memory. Optimize demonstrated bottlenecks while completing features. The scoped #30 amendment is not a global gate waiver; full performance remains under #21/#23/#24.
- Specific new laws require drafting, falsification with planted defects and human approval before ECS proofs. New dependencies and unresolved contract changes require the existing SPEC approvals. Checker default remains five seconds; retain separately approved diagnostic scope without generalizing it.
- Commit verified work directly on master, obtain independent Spec/Standards review, push and post an English governing-issue completion report before closing. Preserve unrelated edits/processes, read-only references and canonical jev. Document any remaining limitation with a concrete owning task; do not close on a feasibility report or silently narrow this acceptance.

## Current bounded evidence map 2026-10-15

Independent Spec/Standards and documentation review by
`debug56_reader_product_oracle` reports PASS for the joined native acceptance
criteria and source-bound evidence below (documentation `31341df9a`, archive
classification `aaa61d991`). The stock 32-case workload includes the TypeScript
comparison. Integrated at `a2442d48d`; CI 38825895705 and the issue completion report passed, and #46 is closed. R7 assigns
comparative timing/scaling to the combined #21/#23/#24 workload, not as a separate
#46 gate.
Reference order is Rust Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
`a950fd683c0d76f09794078e6174fe98a1492876`, then bevy-ts
`3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.

| Evidence slice | What the retained result establishes | Exact boundary |
| --- | --- | --- |
| 32-case ordinary lifecycle — [timed-v5 review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/operation-interval-v1/timed-v5/FINAL-REVIEW.md) | At source root `45129efdf93deb00a54755d55af88974db32ac4c`, 32 actual operations across Workshop and Garden produce matching full 501,886-byte JS, pinned-TS, and Native `-O3` outputs. The observed value is `Public.view` plus embedded owner fields. The plan pins Bend 2.0.35 (`f7741747…`), Node 24.20.0, and Clang 19; times are one-run telemetry only and are not a separate #46 comparative-timing gate. | The public view traverses live entities and their payload/marker fields and includes resource and pending-command observations. It does not serialize the separate `Public.whole`/`App.Report` supplement or all of its metadata/stamp/returned-error/instance/undo fields. The joined 92/22/40 evidence supplies complementary physical state and refusal observations; no extra operation-specific `Public.whole` run is inferred from that projection difference. Its bounded `--check-only` attempt is an expected FFI/unsafe-IO refusal, not a proof. The frozen timed-v5 source basis contains 156 source/tool inputs; its reached `World.pending_length` and some tool pins have since changed, so do not describe that inventory as a current-source join. A distinct 1,323,096-byte candidate-backed `App.Report` run uses private compiler candidate `ac244d4d35eebd4faa0a922d648f7a45d411cb46`; it is supplemental private evidence, not stock compiler qualification. Do not merge its output claim with the stock timed-v5 result. |
| Canonical 92 plus current 22 handle cases — [native reconciliation](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/NATIVE-COMPLETION.md), [22-case review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/native-consuming-current-v1/FINAL-REVIEW.md) | The retained 92-case canonical consumer covers typed construction, nested insert, complete physical state, 14 authority negatives and three reached mutants. The separate current-source 22-case consumer covers two schemas, handle namespace accepts/refusals through component and resource operations, owner recovery, queue and rollback; JS/Native match an 80,800-byte independent oracle. Its 45-file source closure and 73 execution pins are explicitly reviewed; the current entry pins stock Bend 2.0.35 (`f7741747…`) and Clang 19, with JS emit/consumer 30/5s and Native emit/build/consumer 30/120/5s. | The 92-case result is retained source-bound evidence, not a fresh replay against every later source/tool pin; do not transfer another consumer's input inventory or tool scope to it. The 22-case entry does not call `provision_declared`, `SF.bind_declared`, or `descriptor_present`; that branch is represented by separate classified-schema evidence. |
| 40 materialized constructor/resource rows — [materialize-rows-v2 review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/native-resume-v1/codec-variants-v1/materialize-rows-v2/FINAL-REVIEW.md) | Fourteen constructor and six resource rows per nominal schema (28 `ConstructedCase`, 12 `ResourceCase`) retain per-row result, resource/world state, replacement and rollback. The independent 21,488-byte oracle matches JS and Native. Source check passes against 50 source files; runtime plans pin stock Bend 2.0.35 (`f7741747…`) and Clang 19, with JS emit/consumer 30/5s and Native emit/build/consumer 30/120/5s. | This is a finite row consumer; `J.encode` fuel 100,000 is per row, not an aggregate bound. It does not establish every descriptor, constructor-precedence, malformed-error or decode path. |
| Classified-schema authority control — [authority-controls-v2 review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/native-resume-v1/handle-admission-v1/authority-controls-v2/FINAL-REVIEW.md) | Under both nominal schemas, actual declared binding and issued `Cap.Read` reach the absent/exactly-present `HandlePayload` path. Two source/type-check controls reject using that read capability for an owned component request or resource construction. | These are compile-time authority refusals, not runtime denial branches or blanket constructor classification. They complement, rather than replace, the 92/22 runtime observations. |
| Pinned TypeScript reference — [current-source TS review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/native-resume-v1/current-source-ts-binding-v1/FINAL-REVIEW.md) | The unchanged Node 24.20.0 runner executes the pinned bevy-ts reference. Its 32 ordered shared projections match the independently derived common projection. | The supplemental binding covers selected `schema`, `operation`, `name`, and `value.public` fields, not the complete 643,624-byte TypeScript output as a Bend wire or all native authority behavior. The timed-v5 full TS execution is separately scoped to its 32-case public-view output. |
| Reached mutation controls — [canonical native reconciliation](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/NATIVE-COMPLETION.md), [22-case mutant review](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/native-consuming-v1/README.md), [private constructor-precedence counter](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/native-resume-v1/constructor-precedence-v1/fallible-guard-bypass-v1/FINAL-REVIEW.md) | Canonical 92 retains reached skipped-validator/partial-write mutations; the 22-case namespace mutant changes actual issued-codec validation and matches its full JS/Native countermodel. The copied-source constructor-precedence counter changes the two invalid rows and rejects its normal oracle on JS/Native. | The constructor-precedence counter is a private copied-source test with QName rebasing, not current production adoption. Other private observer-routing mutations are not validator controls. Preserve the exact mutation/source boundary when citing a reached defect. |

The stock and private 32-case results are deliberately separate: timed-v5 qualifies
the full ordinary lifecycle's public view and physical owner fields, with the
matched TypeScript comparison, on its frozen source basis; the candidate-compiler
run adds a different whole-report projection. The joined 92/22/40 and
classified-schema evidence supplies complementary physical state, rollback,
handles and authority observations. The existing
[native reconciliation](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/NATIVE-COMPLETION.md)
identifies no uncovered generic native construction API from these joins; the
joined native semantic acceptance review reports PASS. R7 assigns comparative
timing/scaling to combined #21/#23/#24. #46 is closed after integration, independent review, the issue report and CI. #58/#59 save/restore remains separate. This map does not
convert archived Standard Schema/JS-host mechanisms into native acceptance or claim universal coverage.

The four checked criteria above are supported by the joined evidence: descriptor
and primitive inventory with constructor precedence; public typed construction
under two schemas and actual foreign handles; retained affine input and complete
rejected world/queue; reached validator/partial-write controls. The adopted core
already passed the [unchanged #28 gate](../../experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/CORE-DELIVERY.md).
This reconciliation changes no executable source and introduces no new proof claim.

## Selected constructed resource — existing API composition

A Product-backed World can construct one declared resource without replacing its
siblings. Use `decode-construction.fallible_construct`, validate the cooked owner
with `persistence-declaration.validate` on the same retained Constructed declaration,
then call `ordinary-resource-field-system.set` only for Accepted. Input admission
alone does not establish cooked-value admission. On refusal, retain the actual
input or cooked owner plus undo; the [ordinary public callback](../../experiments/public-construction/selected-resource-v1/fixture.bend)
uses the existing field grant, without a new provider or raw World access.

The [complete consumer](../../experiments/public-construction/selected-resource-v1/scenario.bend)
passes stock JS/Native against26,673 independent bytes. Two nominal WorldIO schemas
retain Target, a same-payload sibling and an unlike affine owner; the cooked
refusal is observed before actual undo and retry of the returned input. Trusted
setup derives expected namespace from the actual World, separately from raw input.
Clock/cursor remain0 and pending1 throughout this finite trace. Refusals are handled
operation results, not new failed-system rollback cases. Handle validation checks
namespace and positive ID, not entity liveness. Undo closures are opaque until
actually invoked; bounded rendering reports exhaustion explicitly (absent here).

This is a source-current #61 composition witness using unchanged core APIs; #46's
closed whole-resource evidence keeps its existing scope. Retained TS constructor
and keyed-sibling observations are complementary subsets, not a new combined
TS/Bend wire comparison; see [exact applicability](../../experiments/public-construction/selected-resource-v1/TS-APPLICABILITY.md).
Both backend mutation outputs match the independent 26,453-byte counter oracle and reject the complete normal output. One positive and four intended authority/affine refusals pass; seven applicable read controls are reused. All 135 imported core bodies remain unchanged. [Independent final review](../../experiments/public-construction/selected-resource-v1/FINAL-REVIEW.md) passes. Integrated `0b025defe`; CI38919912200 PASS. This does not close full #61.
