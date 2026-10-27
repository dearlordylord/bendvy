# Execution law draft inventory

Source reconciliation at `a417eb88778aa5efc49ba193b613a8cc435d7f05`.
Of the 36 subjects below, 35 remain **DRAFT / UNAPPROVED / UNPROVED**.
The user approved only `pending_returns_actual_application` at snapshot
`fd6826220899f261994a4a77260d6c2049e1caed`; its unchanged statement is kernel-proved
in [the isolated proof](../../test-fixtures/execution-save-laws/pending-approved/PROOF.bend),
with [source binding and scope](../../test-fixtures/execution-save-laws/pending-approved/SUBJECTS.json).
This status does not approve any other subject or establish whole-capability acceptance.
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
| [lifecycle](../../test-fixtures/execution-lifecycle-laws/LAWS.bend) | 13 active | Actual `Sys.Owner`, `Sys.Body`, `Build.FrameworkProgram`, `World`, `Scope`, administration, journal, lifecycle Reader and typed command entry | Four wrapper laws are conditional on exact `IO.pure` invocation/kernel terms. They do not cover arbitrary effectful IO. Other laws pin result reassembly, Finished/Stopped/Invalid maintenance branches, foreign admission/Reader/command-entry refusal, and one retained-item lag shape. No whole-run scheduling, driver behavior or full retention search theorem. |
| [relations](../../test-fixtures/execution-relation-laws/LAWS.bend) | 7 | Interpreter allocator/graph, protected-write policy, actual Store/slot/stamp, actual failure Reader/channel and Local | Foreign unrelate/store/publication/Reader refusals, ordinary-descriptor reorder refusal, policy helper, and body-error reassembly. No successful arbitrary graph edit, public grant completeness, registration, false-condition path or rollback theorem. |
| [relation context](../../test-fixtures/execution-relation-context-laws/LAWS.bend) | 1 | `WorldPublication.apply`, actual World, typed Context.Binding and original operation | Assumes the exact `W.namespace` observation and namespace inequality. Preserves that World/binding on refusal; does not prove namespace allocation, ordinary Root wiring, successful publication or maintenance. |
| [save gate/recipe](../../test-fixtures/execution-save-laws/LAWS.bend) | 4: 1 approved/proved, 3 drafts | `Gate.checked`, actual generic application owner; `Recipe.export`, actual payload/recipe | Only the supplied pending Bool branch is proved to retain the actual application and return RefusedPending. The clear/projector, Plain and Transient equations remain drafts. No pending detection, arbitrary projector preservation, serialization or schema theorem. |
| [save schema](../../test-fixtures/execution-save-laws/SCHEMA.bend) | 2 | `Save.ready` and `Save.eligible`, actual schema and World | Exact pending-readiness and supplied schema-error branches. No success-path export, derived pending fold, ordering or codec theorem. |
| [restore helpers](../../test-fixtures/execution-save-laws/RESTORE.bend) | 3 | `Receiver.ready`, `Publish.publish`, `Clear.clear`, actual World | Pending receiver refusal and empty publication/clear lists only. No nonempty restore, fresh allocation, remapping, graph reconstruction, stream/Reader preservation or lifecycle theorem. |

The lifecycle source now uses `Ops:Data -> Type -> Type`,
`Build.FrameworkProgram`, and `Sys.Body`; the invocation and wrapper equations
now have their actual `IO(...)` types. The conditional equations require exact
`IO.pure` terms, not an assertion that arbitrary effects reduce to a returned
value. This narrower IO domain is explicit and is **not** whole-run coverage.
A single source-only `--check-only` invocation reports 13 unfinished laws and no
other diagnostic for that file. Its exit status is 1; it is not a proof pass.
The other groups were reconciled by reading their current subjects/signatures;
no successful proof or blanket source-check claim is made for them.

`foreign_family_entry_retains_world_and_incoming_owner` now has a current
statement. Its pre-migration text remains commented as history in the lifecycle
source, not as an additional candidate. The active equation supplies the actual
resource layout and equality proof, typed `Permission.Selection` (including its
scope dispatcher), `Permission.Relations` and Context to `Publication.entry`.
It retains the full-World/incoming-owner refusal conclusion, with only valid-route
and namespace-inequality premises. It does not assume a final publication result
or replace actual owners with a policy Boolean. The selected `Buffer.Entry`
family branch does not execute relation/scope dispatch or check Context admission.
The current API requires the resource-layout equality witness. The successor
does not quantify over an opaque `R` without that witness as the old text did.
There are still **36 existing subjects**, with one approved/proved and 35 active
drafts; none is blocked by the old signature. Active means an uncommented
declaration, not approval, proof or a successful source check for every draft file.

Receiver quiescence is a separate law gap. `receiver_pending_keeps_actual_world`
only fixes the `Receiver.ready(...,(world,False{}))` branch. It does not prove
that `Receiver.prepare` rejects active `Clock.scopes`. The current typed
`ActiveExecution` admission branch returns actual World before columns,
constructors, clock-floor changes or mutation. No current draft above establishes
that branch. The current receiver implementation has this decision:
`Receiver.ready(...,(world,True{}))` proceeds to column inspection only for
`Clock.State{tick,[]}` and otherwise returns
`Receiver.Refused{world,Receiver.ActiveExecution{}}`. This is integrated source
in the reconciliation basis above, not a proof or an additional law candidate.

The same limit applies to other subsequently integrated APIs. No existing draft
above establishes `Recipe.Changed` from actual column/cached stamps and the
admitted `Scope.prior/tick`; arbitrary retained N-leaf composition and nested
cut/join refusal; generalized Root `run_bound` preflight; or its owned completion
callback and whole-schema relation failure maintenance. The lifecycle maintenance
equations name `Maintenance.completed`, not those generalized Root adapters.
The pure lifetime-scope and recoverable-component type splits do not extend any
of these equations into cleanup, recovery or whole-run theorems. These are
uncovered subjects to resolve separately, not hidden coverage in the 36 drafts.

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
| Lifecycle | Сохраняются возвращённые владельцы; обслуживание истории зависит от результата; чужие Reader и команда записи отказываются работать с этим World. | Часть утверждений условная; IO ограничен точными `IO.pure` термами; закон команды записи не доказывает Root, Context admission или обработку relations/scopes. |
| Relations и Context | Перечисленные отказы сохраняют graph, allocator, Reader, binding и входную операцию; обычная запись в защищённый ресурс запрещена. | Нет общего доказательства правильности изменения графа или выдачи полномочий. |
| Save | При pending работа не сохраняется, а реальные владельцы возвращаются; Plain/Transient следуют своей политике. | Нет доказательства обнаружения всей pending-работы, кодеков и произвольных projectors. |
| Restore | Отказ при pending и пустые шаги возвращают настоящий World. | Непустое восстановление, remapping, Reader и stream ещё не покрыты этими законами. |
