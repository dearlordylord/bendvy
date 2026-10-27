# Execution law draft inventory

Source reconciliation at `9b18a2a0c9fcde3159769125a77e4361d417bb28`.
Every candidate below is **DRAFT / UNAPPROVED / UNPROVED**. This is authoring,
not an independent review, approval request, proof run or acceptance report.
The five previously approved statements under `test-fixtures/execution-laws`
are outside this change and remain frozen.

## Current draft subjects

Paths below are relative to the repository root. A group count includes each
existing named statement; no new law was added and no weaker replacement was
substituted for a blocked statement.

| Draft source | Statements | Actual current subject | Exact semantic limit |
| --- | ---: | --- | --- |
| [reservation service](../../test-fixtures/execution-reservation-laws/LAWS.bend) | 2 | `Task.service_generic`, actual `Issuer` allocator, `Authorized` permit and continuation | Foreign namespace `1` against issuer `0`, or empty prepared-ID list, returns issuer and a deferred refusal continuation. No successful allocation, continuation execution, arbitrary task tree, or whole-run claim. |
| [reservation materialization](../../test-fixtures/execution-reservation/LAWS.bend) | 4 | `Materialization.apply_at`, `check_leaf`, actual World, allocator, unlike bundle and column owners | Foreign namespace; one-cell malformed value array against eight-cell canonical leaf; a specific old generation; a specific Consumed allocator slot. Does not establish successful publication, all malformed layouts, or reservation provenance. |
| [lifecycle](../../test-fixtures/execution-lifecycle-laws/LAWS.bend) | 12 active + 1 blocked | Actual `Sys.Owner`, `Sys.Body`, `Build.FrameworkProgram`, `World`, `Scope`, administration, journal and lifecycle Reader | Four wrapper laws are conditional on exact `IO.pure` invocation/kernel terms. They do not cover arbitrary effectful IO. Other laws pin result reassembly, Finished/Stopped/Invalid maintenance branches, foreign admission/Reader refusal, and one retained-item lag shape. No whole-run scheduling, driver behavior or full retention search theorem. |
| [relations](../../test-fixtures/execution-relation-laws/LAWS.bend) | 7 | Interpreter allocator/graph, protected-write policy, actual Store/slot/stamp, actual failure Reader/channel and Local | Foreign unrelate/store/publication/Reader refusals, ordinary-descriptor reorder refusal, policy helper, and body-error reassembly. No successful arbitrary graph edit, public grant completeness, registration, false-condition path or rollback theorem. |
| [relation context](../../test-fixtures/execution-relation-context-laws/LAWS.bend) | 1 | `WorldPublication.apply`, actual World, typed Context.Binding and original operation | Assumes the exact `W.namespace` observation and namespace inequality. Preserves that World/binding on refusal; does not prove namespace allocation, ordinary Root wiring, successful publication or maintenance. |
| [save gate/recipe](../../test-fixtures/execution-save-laws/LAWS.bend) | 4 | `Gate.checked`, actual generic application owner; `Recipe.export`, actual payload/recipe | Pending Bool branch retains application; clear branch calls exact supplied projector; Plain refuses and Transient omits while retaining owners. Does not prove pending detection, arbitrary projector preservation, serialization or schema correctness. |
| [save schema](../../test-fixtures/execution-save-laws/SCHEMA.bend) | 2 | `Save.ready` and `Save.eligible`, actual schema and World | Exact pending-readiness and supplied schema-error branches. No success-path export, derived pending fold, ordering or codec theorem. |
| [restore helpers](../../test-fixtures/execution-save-laws/RESTORE.bend) | 3 | `Receiver.ready`, `Publish.publish`, `Clear.clear`, actual World | Pending receiver refusal and empty publication/clear lists only. No nonempty restore, fresh allocation, remapping, graph reconstruction, stream/Reader preservation or lifecycle theorem. |

The lifecycle source now uses `Ops:Data -> Type -> Type`,
`Build.FrameworkProgram`, and `Sys.Body`; the invocation and wrapper equations
now have their actual `IO(...)` types. The conditional equations require exact
`IO.pure` terms, not an assertion that arbitrary effects reduce to a returned
value. This narrower IO domain is explicit and is **not** whole-run coverage.
A single source-only `--check-only` invocation reports 12 unfinished laws and no
other diagnostic for that file. Its exit status is 1; it is not a proof pass.
The other groups were reconciled by reading their current subjects/signatures;
no successful proof or blanket source-check claim is made for them.

`foreign_family_entry_retains_world_and_incoming_owner` remains blocked.
Its original statement is retained as commented draft text in the lifecycle
source. `Publication.entry` now requires the actual resource layout, its equality
proof, typed `Permission.Selection` and Context, in addition to the old arguments.
The ScopeGrant/Buffer migration owns the next concrete signature. Reauthor that
same full-World/incoming-owner refusal statement after that API lands; do not
replace it with a policy Boolean law or assumed final publication result.

Receiver quiescence is a separate gap. `receiver_pending_keeps_actual_world`
only fixes the `Receiver.ready(...,(world,False{}))` branch. It does not prove
that `Receiver.prepare` rejects active `Clock.scopes`. The incoming typed
`ActiveExecution` admission change must retain actual World/App before columns,
constructors, clock-floor changes or mutation. No current draft above establishes
that new branch. The receiver owner reports the concrete pending change:
`Receiver.ready(...,(world,True{}))` proceeds to column inspection only for
`Clock.State{tick,[]}` and otherwise returns
`Receiver.Refused{world,Receiver.ActiveExecution{}}`. This incoming signature
was communicated before its coherent commit; it is not claimed as integrated
source in the reconciliation basis above.

## Bevy correspondence and Bend requirements

All correspondence comments pin Bevy
`ad678262ce53b5d142fe49ee5e08caff6f00ab60`. The relevant code is
[Commands reservation and deferred insertion](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/commands/mod.rs),
[App tracker maintenance](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs),
[relationship source/target correspondence](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs),
[message cursor counts](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs), and
[executor error/deferred handling](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs).
These links explain behavioral motivation. Exact affine owner return, namespace
refusal, typed grants and save-policy refusal are Bend requirements. Bevy code
is not a proof of those equations or of matching ownership representations.

## Кандидаты простыми словами

Все строки этой таблицы — **черновики, не одобрены и не доказаны**.

| Кандидаты | Что они обещают | Где заканчивается обещание |
| --- | --- | --- |
| Reservation: отказ в полномочиях | При чужом namespace или неподготовленном ID настоящий allocator остаётся у владельца. | Не обещают успешного выделения сущности и не запускают продолжение. |
| Spawn: отказ публикации | При перечисленных ошибках возвращаются настоящий World и исходный пакет компонентов. | Охвачены конкретные формы ошибок; успешный Spawn не доказан. |
| Lifecycle | Сохраняются возвращённые владельцы; обслуживание истории зависит от результата; чужой Reader отказывается читать. | Часть утверждений условная; IO ограничен точными `IO.pure` термами; одна публикация заблокирована изменением API. |
| Relations и Context | Перечисленные отказы сохраняют graph, allocator, Reader, binding и входную операцию; обычная запись в защищённый ресурс запрещена. | Нет общего доказательства правильности изменения графа или выдачи полномочий. |
| Save | При pending работа не сохраняется, а реальные владельцы возвращаются; Plain/Transient следуют своей политике. | Нет доказательства обнаружения всей pending-работы, кодеков и произвольных projectors. |
| Restore | Отказ при pending и пустые шаги возвращают настоящий World. | Непустое восстановление, remapping, Reader и stream ещё не покрыты этими законами. |
