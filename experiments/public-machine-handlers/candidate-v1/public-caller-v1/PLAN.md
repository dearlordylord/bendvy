# Independent core-only handler caller — source proposal

Draft for implementation/review, not executed acceptance. Governing issue #49 explicitly requires independently authored public application operations; existing full96/12 qualifies the implementation, but its full-provider/context/actions helpers form a large coupled test harness. This caller will be authored from public module signatures and the following application contract, without importing or copying those runtime helpers. It checks the ability to assemble an application, not another implementation-level failure matrix.

## Application contract (existing approved behavior)

Two nominal schemas each construct an actual independently owned world with one affine Array<U32> component, an affine resource owner, one Boot/Play/Pause machine, registered exit/transition/enter systems, one Local.Cell per actual registration, and an actual tracked reader cursor. One machine is processed per marker; no disputed later-key policy is exercised.

A closed transition system fails once after attempting gameplay writes. Exit already committed +1; transition attempted +10 rolls back its own gameplay writes; its Local attempt remains incremented. Original Boot and queued Play survive. Retry reruns exit, commits transition +10, publishes once, then enter commits +100 and queues Pause. Pause is not processed until the next explicit marker. Enter queues only when the target is Play. Local owners remain in trusted schema/namespace/SysID storage, accessed only inside the validated runner; this adds no public Local ownership contract. All owner values and registries are threaded back on failure.

A heterogeneous condition uses the existing pure Tree evaluator over schema-bound metadata. A false condition skips before Local/transaction/reader access. Requirements are validated before condition/callback execution. Publication and reader acknowledgement use public machine-stream and actual Sys.run_tracked cursor boundaries; no raw internal event helper is imported and no general owned-event policy is introduced.

## Files to implement

- `types.bend`: independent schema, state/key, component/resource/Aux owners and closed callback argument types. No experimental imports.
- `world.bend`: application-specific lenses built with qualified machine-world; observation consumes and returns affine owners.
- `systems.bend`: actual registry registration, requirement grants, closed callbacks, Local operations and exact per-system transaction inverse. No universal Type clone.
- `application.bend`: phase-owner assembly, heterogeneous condition and explicit single-machine marker call; schemas A/B instantiate the same generic application.
- `main.bend`: compact complete observation exports; no acceptance claim from literal construction.
- `expected.json` / `consumer.mjs`: independently authored application checkpoints and exact full-output consumer, not copied full-provider oracle code.

Direct dependency closure: Base and src/ecs world, column/component, capabilities, system, transaction, local, machine, machine-stream, machine-handlers, staged machine-world and machine-conditions. Schema adapter code is ordinary application code. Helpers bind to already qualified bytes world8b8610e7/conditions61091256; actual root adoption remains root-owned. Existing core API stays unchanged.

## Independent observation contract

For each schema observe current/pending/previous/changed, actual component contents, resource contents, every Local owner value, all retained registry IDs/namespaces/cursors, transition stream length and actual read deliveries, queued structural work and exact applied-prefix log. Four checkpoints: initial, failed transition, successful retry, next marker. Add false-condition and missing-requirement before-callback controls with unchanged owners/cursors/logs. Expected arithmetic is specified below, then independently encoded before source implementation:

| Checkpoint | Gameplay total | Local exit/transition/enter | Current / pending | Published transitions |
|---|---:|---|---|---:|
| initial | 0 | 0/0/0 | Boot / none | 0 |
| failed transition | 1 | 1/1/0 | Boot / Play | 0 |
| retry | 112 | 2/2/1 | Play / Pause | 1 |
| next marker | 223 | 3/3/2 | Pause / none | 2 |

Array/resource/structural effects need concrete independently specified values when callback source is drafted; do not infer expected values from generated output. Reader logs must contain exactly Boot→Play then Play→Pause, with cursor advancement only after successful tracked reads. Failed callback returns actual Sys.Failed; never coerce success to advance a cursor.

## Minimal qualification sequence

1. Source review the independent contract and actual public import/ownership boundaries. If signatures force internal/experimental runtime imports, report the concrete API gap before adding convenience APIs.
2. Draft caller and independent complete oracle. Development source5 for the one affected root first; precise undeclared write/read and cross-schema caller refusals only where newly composed boundaries need coverage. No tool discovery or backends before frozen reviewed plan.
3. Fresh bounded JS emit30/full consumer5 for this new caller and oracle; existing full96/12 is not replayed for packaging. Native partition plan only after actual JS passes and emission complexity is known, caps unchanged.
4. Source/runtime acceptance and portability review. Root owns two-helper adoption/new inventory and combined #28 gate. Equivalent full feature timing and #48 acceptance remain separately owed; this example does not close either issue or prove universal properties.

No new laws, capture policy, stream representation, numeric threshold or dependency is selected. Registration/marker shorthand is considered only if the caller demonstrates a specific repeated public boilerplate seam; avoid wrapping trusted fixture policy into a general API.
