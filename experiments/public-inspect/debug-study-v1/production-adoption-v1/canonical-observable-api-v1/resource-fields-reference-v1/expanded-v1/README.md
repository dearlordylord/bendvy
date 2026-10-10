# Expanded #70 TS reference (preparation)

Pinned bevy-ts `3040a3b2` supplies reference scenarios, not the governing Bend
contract. Rust Bevy capabilities come first and Bend ownership/runtime second.
This additive fixture preserves the earlier qualified selected-resource test.
No Node execution or expanded comparison is qualified yet.

The fixture uses actual public bound Runtime, System, Inspector, Schedule and
Command APIs. A/Other scenarios create two entities with Cell components,
publish events 91/92, register an unrelated system, and queue a Marker=99
component insert. Actual resource runs perform repeated First writes and a
sibling write, commit, typed failure rollback and retry. Pending insertion stays
invisible through those runs and becomes visible at explicit applyDeferred.
Full debug dumps retain entity/component/resource values, pending command
origins, frame and tick. Declared system names/accesses are observed repeatedly.
No fixture rollback or manual state restoration is used.

The independent `expected.py` computes every observation before execution.
TS-only clock values follow runSystem/commit publication/applyDeferred/inspect:
setup reaches tick six, then snapshots produce ticks 7/9/11/13/15. Those are
not assertions that Bend's stable clock three or Registry cursor equals TS.
Fresh event inspectors advance their own readers; a real HoldEvents system
registers a retained reader before publication so 91/92 remain available across
frames. Repeated debug.dump/describe calls themselves preserve their output.

| Expanded boundary | Exact scope and limitation |
| --- | --- |
| Selected writes and rollback | Common complete numeric arrays and operation order; actual TS Runtime first-original journal performs rollback. |
| Two live component owners | TS Cell records verify membership and values; they do not verify Bend Array capacity/depth or affine owner representation. |
| Nested untouched sibling | Complete values/flags preserved; independent JS resource object is not Bend's physically nested affine lens. |
| Registration/access | Public declared systems/access/order observed; TS exposes no equivalent typed Registry owner, ID or cursor. |
| Pending barrier | Structural Marker insertion is a labelled queue-visibility analogue. It is not Bend's queued callback publishing event 99. |
| Seed events | Actual 91/92 publication and retention verified using public stream readers. No TS event-99 callback is synthesized. |
| Duplicate provisioning | Actual Schema.bind throws for duplicate registry key First; Bend returns typed DuplicateKey data. |
| Missing provisioning | Actual tryTick refuses physically absent Second before running a system and preserves the entire dump. This differs from Bend Fragment descriptor-list absence with returned affine owners. |
| Valid provisioning | Actual tryTick executes the ordinary resource system. It is not an identity Fragment initializer. |

The public TS CommandsApi explicitly reserves commands for structural writes;
resource/event writes use declared system accesses (`Command.ts:403`). In
contrast Rust Bevy's CommandQueue accepts Commands applied to World, and World
supports write_message (`world/command_queue.rs:102`, `world/mod.rs:3039`). The
TS omission does not constrain the accepted Bend callback behavior.

Primary source basis: TS Runtime transaction journal/rollback (`Runtime.ts:997`),
runSystem (`:1387`), deferred application (`:1439`), tryTick (`:1674`), Inspector
reader advancement (`:1695`), complete debug dump (`:1886`); schema runtime guards
(`internal/fragments.ts:20`). Rust system resource ticks remain per-system
(`system/system_param.rs:910`). Exact source hashes are in SOURCE-BASIS.json.

`run.py` is byte-identical to the already reviewed five-second Node adapter.
Its single Node child requires an external shared lock, exact Node24.20/tool
pins, sanitized environment and independent whole stdout. The #56 remaining
batch has priority; preparation does not authorize an overlapping launch.
No full #70 closure, affine destruction, process identity, numerical cursor
equivalence, statistical performance result or unsupported initializer policy
is inferred from this reference.
