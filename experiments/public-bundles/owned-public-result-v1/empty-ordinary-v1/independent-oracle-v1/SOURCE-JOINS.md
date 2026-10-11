# Empty ordinary bundle finite model basis

This independently authored model consumes source03 and no producer backend output. The complete formatter is `List<String>` with explicit field rendering, so nominal First/Second and module paths do not print constructor QNames. Base `Bool.show` prints False/True, inner `List.show` uses the supplied identity/meta renderers without String quoting, and the CLI quotes outer strings and appends LF.

Pinned Rust Bevy `bundle/impls.rs:176` expands tuple bundles beginning at arity zero; `World::spawn_empty` supplies an entity without components. These primary sources justify the empty-bundle category, not a new Bend allocator/identity policy. Existing Bend implementation determines the finite execution details:

| Reached source operation | Independent model consequence |
| --- | --- |
| Consumer request calls public Ordinary.terminal/request; Ordinary validates the empty list and forwards to Cmd.request | Empty declarations admit the operation without a fabricated component family. |
| CS.terminal returns Valid with same context, Unit cooked/raw, identity inverse and no positions | Context Array is retained; missing insertion recovers original Unit through Packet.unpack. |
| Provider.provide_owned constructs OwnedRequest and invokes the polymorphic consumer body via Cap.owned_request | The ordinary registered runner reaches opaque owned request, not a direct fixture-only substitute. Raw provider callback remains trusted. |
| W.factory/create/register and consumer main's First→Second factory threading | Namespaces 1 and 2, factory 3, one registration in each World; metadata/access remain visible. |
| BT.spawn→Cmd.tx_spawn→W.reserve_id; BT.finish→stage→Cmd.tx_finish | Reservation changes next/high/live capacity immediately. Activation and empty packet delivery commit as two pending closures in authored FIFO order. |
| W.barrier drains those closures; consumer attempt returns its complete World | Live id1 becomes True; all four Store/Resources Array trees survive; no component insertion or clock advance occurs. |
| Insert on actual returned live handle | One empty delivery queued, then consumed by barrier. Empty repeated barriers preserve the complete state. |
| Insert Handle{0,0}→W.valid False→no reservation receipt→BT.Refused→unpack | MissingEntity with original Unit raw, no pending addition or World/context mutation. This invalid admin handle is not a same-schema foreign-World witness. |
| Sys.run_tracked sees Succeeded containing Refused output, then W.clock | Cursor remains clock 0 on all three requests. Value-level refusal is distinct from Sys.Failed. |

The model selftests both schema lifecycles, reservation-before-activation, exact pending 2/1/0, callback order, complete owner values, repeated barriers and missing-state equality. It produces all eight observations per schema plus Factory, not projected counts alone. Consumer recovery/drop branches are source-typed but not reached by these successful delivery callbacks. No arbitrary packet failure/undo proof, cleanup/finalizer/cancellation law, new #38 identity guarantee, runtime evidence or feature timing is inferred. A reached candidate mutation or authority refusal needs its own frozen subject; none is invented by this model.
