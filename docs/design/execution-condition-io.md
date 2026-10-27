# Canonical condition registry IO

The condition registry owns each actual guard and its retained Compilation in a
`Scope.CompiledBinding`. A leaf dispatch checks the requested registration ID,
then passes that Compilation and owner to `Sys.run_retained_compilation`. The
returned IO value includes the Compilation, actual System owner, and World before
its completion is translated to `Completed`, `BodyError`, or `AdmissionRefused`.
The adapter retains Local, cursors, World writes, and the captured tick. The
System kernel owns namespace, registration, supported-compilation admission,
clock entry, opaque permit qualification, and issuer service.

`execution-condition-registry.Registry<World,Owners,Error,dispatch>` stores
`owners`, the derived `nodes`, and `invalid`. Its dispatch has type
`Owners -> World -> U32 -> IO(Owners & (World & Invocation<Error,Bool>))`.
`Selection` exposes retained typed leaves, product joins, and empty registries.
`compile` interprets the selection with `compile_retained_leaf`. Admission derives
requirements and read-only permission from the actual retained Compilation.
Unsupported compilation marks the condition invalid. Product dispatch retains
the unselected affine sibling. Registry admission and dispatch do not recompile
the framework declaration.

`leaf`, `paired`, and `empty` are the public selection helpers. `leaf` accepts a
`RetainedSystem` and an erased construction Compilation. The factory supplies
that closed witness for the capability specialization. The actual runtime
Compilation remains inside the binding through success, body error, and refusal.
The witness is a trusted construction boundary, not a proved theorem that every
runtime Compilation equals the witness. `System` names the actual owner component
inside `RetainedSystem` and carries its closed `FrameworkProgram`.

`RetainedLeaf`, `RetainedSelection`, and `compile_retained` name the same retained
interpretation for existing callers. Empty selections keep their `Unit` inventory
and `empty_dispatch`. Root application parameters remain unchanged. The raw-owner
leaf compiler and dispatch adapters, and the separate parallel-registration
`condition_registry` adapter, have been removed.

The registry uses the same IO Ready/Deferred scheduler as ordinary applications.
The scheduler awaits conditions before classifying enabled, disabled, and error
status. False conditions do not dispatch the system body. Whole-application
Finished maintenance remains outside this adapter.

The generic pure `dependency-registration` remains for legacy Data dispatch.
Its registry/composer selection embeds an already constructed pure registry or
joins and empties it. It has no System, partition, or root-cut adapter. Historical
fixtures using those legacy modules do not qualify this condition registry.

## Dependency semantics and pinned Bevy

The reference is Bevy commit
[`ad678262ce53b5d142fe49ee5e08caff6f00ab60`](https://github.com/bevyengine/bevy/tree/ad678262ce53b5d142fe49ee5e08caff6f00ab60).
The following mapping concerns dependency ordering and returned errors. It does
not claim identical executors or a general affine ownership theorem.

| Contract | Pinned Bevy code and behavior | Current Bend path |
| --- | --- | --- |
| Dependencies order completion, independently of predecessor success. | [`before_inner` / `after_inner`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/config.rs#L128-L156) record ordering; [`chain`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/config.rs#L558-L566) orders successive elements. The serial executor [marks completion before dispatch and handles returned errors](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L125-L162). | [`Plan.ready`](../../src/ecs/dependency-plan.bend) tests pending predecessors. [`Ready.dispatched`](../../src/ecs/execution-parallel-schedule.bend) removes completed selections, including body errors, before handling them. [`run_serial`](../../src/ecs/execution-parallel-root-application.bend) supplies serial group dispatch to the same scheduler. |
| Conditions observe the World available when reached. | [System conditions use the current World; set conditions are cached after their first evaluation in that run](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L82-L116). There is no blanket schedule-start snapshot. | `Ready.filter_conditions` threads each returned state. Root application `guard_selected` passes its current World to the retained guard. A dependent becomes ready after predecessor removal, so its condition receives dependency-established state. [`Machine.body_sync`](../../examples/parallel-machines/conditions.bend) actually reads the machine field through its declared capability. |
| A handled body error preserves earlier writes and permits continuation. | The [body-error branch](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L137-L162) calls the handler, then continues if it returns. The same mutable World is used; this is a source-based inference of no transactional rollback. | `Ready.dispatched` retains returned state and records `BodyFailed`. `body_handled` continues eligible dependent and independent work on `Continue`; `Escalate` returns `Stopped` with that state. |
| False, condition error, body error, and admission refusal remain distinguishable. | [Condition evaluation](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L239-L274) reports a failed condition to the handler and returns false if the handler returns. Explicit false also skips the body. | `Ready.conditioned` records `Skipped`, `ConditionFailed`, or `ConditionRejected`; `completion_event` records `BodyFailed` or `AdmissionRejected`. Separate report variants, affine owner return, and admission refusal are Bend policy, not Bevy equivalence claims. |

Ordering does not alone promise visibility of deferred commands. Bevy documents
the inserted `ApplyDeferred` behavior and its exceptions for
[`before` / `after`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/config.rs#L368-L405).
Bend's [`execution-deferred-schedule`](../../src/ecs/execution-deferred-schedule.bend)
tracks unapplied systems and explicit synchronization policy separately.
Neither comparison promises continuation after a fatal process exit or an
escaping handler failure. Bevy's
[unwind handling](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L279-L325)
does not turn every fatal exit into an ordinary returned error.

## Existing consumer observations and limits

These receipts bind existing product executions to their recorded source, not to
every later canonical commit. No new execution or comparison was performed for
this source mapping.

| Consumer and source | Recorded observation | Limit |
| --- | --- | --- |
| Machine, `96112c9e75b547a02e38b9dcdec86687ec1cfa43` | `/tmp/conditions79-retained-default-receipt.md`: four updates; JS stdout `/tmp/conditions79-machines-js.stdout`, one line, 7,239 bytes. | Direct retained leaves; does not qualify nonempty `Conditions.compile`. Native emission timed out in this receipt. |
| AppA, `b56862b257e9f76992de84a0e5b3c00ecacd4071` | `retained79-app-a-condition-delivery.md` in the GH78–94 orchestration record: JS/native full comparison passed, 22 lines, 5,867 bytes; both Off/On guards retain three calls and cursor `0:17`. | Finite retained-owner observation; no general construction-witness coherence theorem or independent full-World derivation. |
| Events, `f81afeef1be3ae57bba14107684c5822eb53d596` | `native79-retained-condition-delivery.md` in the same record: eight original modes, five passes each; JS/native full comparison passed, eight lines, 17,291 bytes, including body-error writes and foreign-reader refusal. | Recorded source only; opaque pending callbacks are not extensionally observed. |

These are ordinary Bend consumer receipts. They do not supply an executed,
focused pinned-Bevy scenario comparison for GH79, independently derive the
complete World, or establish whole-issue completion. The source mapping above
identifies the behavior such a comparison would need to distinguish.
