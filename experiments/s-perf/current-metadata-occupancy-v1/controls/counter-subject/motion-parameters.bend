import Base
import motion-report-doc.bend as Doc
import motion-runtime-observe.bend as RuntimeObserve
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-family.bend as Family
import motion-logical.bend as Logical
import ../../private/src/ecs/reader-parameter.bend as RP
import ../../private/src/ecs/ordinary-reader-query-parameter.bend as QP
import ../../private/src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../private/src/ecs/inspector-query-projection.bend as Projection
import ../../private/src/ecs/event-runtime.bend as Ev
def allrows_owner() -> Type:Unit
def allrows_view() -> Data:QP.Rows<T.MotionSchema,Logical.Value()>
def allrows_delta() -> Type:Unit
def allrows_validate(context:Family.Context(),owner:allrows_owner()) -> Family.Context() & (allrows_owner() & Bool):QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration())(context,owner)
def allrows_prepare(context:Family.Context(),+cursor:U32,owner:allrows_owner()) -> Family.Context() & (allrows_owner() & (allrows_view() & allrows_delta())):QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration())(context,cursor,owner)
def allrows_commit(context:Family.Context(),owner:allrows_owner(),delta:allrows_delta(),+cursor:U32) -> Family.Context() & allrows_owner():QP.commit_context(~Family.Context())(context,owner,delta,cursor)
def allrows_release(context:Family.Context(),owner:allrows_owner()) -> Family.Context():QP.release_context(~Family.Context())(context,owner)
def allrows_parameter_type() -> Data:RP.Param<Family.Context(),allrows_owner(),allrows_view(),allrows_delta(),allrows_validate,allrows_prepare,allrows_commit,allrows_release>
def allrows_converted(value:RP.Param<Family.Context(),allrows_owner(),allrows_view(),allrows_delta(),QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration()),QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration()),QP.commit_context(~Family.Context()),QP.release_context(~Family.Context())>) -> allrows_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def allrows_parameter() -> allrows_parameter_type():allrows_converted(QP.from_observable(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration()))
def allrows_initialize(context:Family.Context(),_:RP.RegistrationFacts) -> Family.Context() & (allrows_owner() & allrows_parameter_type()):(context,(Unit{},allrows_parameter()))
def added_owner() -> Type:Unit
def added_view() -> Data:QP.Rows<T.MotionSchema,Projection.Product<Unit,Logical.Value()>>
def added_delta() -> Type:Unit
def added_validate(context:Family.Context(),owner:added_owner()) -> Family.Context() & (added_owner() & Bool):QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.added())(context,owner)
def added_prepare(context:Family.Context(),+cursor:U32,owner:added_owner()) -> Family.Context() & (added_owner() & (added_view() & added_delta())):QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.added())(context,cursor,owner)
def added_commit(context:Family.Context(),owner:added_owner(),delta:added_delta(),+cursor:U32) -> Family.Context() & added_owner():QP.commit_context(~Family.Context())(context,owner,delta,cursor)
def added_release(context:Family.Context(),owner:added_owner()) -> Family.Context():QP.release_context(~Family.Context())(context,owner)
def added_parameter_type() -> Data:RP.Param<Family.Context(),added_owner(),added_view(),added_delta(),added_validate,added_prepare,added_commit,added_release>
def added_converted(value:RP.Param<Family.Context(),added_owner(),added_view(),added_delta(),QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.added()),QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.added()),QP.commit_context(~Family.Context()),QP.release_context(~Family.Context())>) -> added_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def added_parameter() -> added_parameter_type():added_converted(QP.from_observable(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.added()))
def added_initialize(context:Family.Context(),_:RP.RegistrationFacts) -> Family.Context() & (added_owner() & added_parameter_type()):(context,(Unit{},added_parameter()))
def changed_owner() -> Type:Unit
def changed_view() -> Data:QP.Rows<T.MotionSchema,Projection.Product<Unit,Logical.Value()>>
def changed_delta() -> Type:Unit
def changed_validate(context:Family.Context(),owner:changed_owner()) -> Family.Context() & (changed_owner() & Bool):QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.changed())(context,owner)
def changed_prepare(context:Family.Context(),+cursor:U32,owner:changed_owner()) -> Family.Context() & (changed_owner() & (changed_view() & changed_delta())):QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.changed())(context,cursor,owner)
def changed_commit(context:Family.Context(),owner:changed_owner(),delta:changed_delta(),+cursor:U32) -> Family.Context() & changed_owner():QP.commit_context(~Family.Context())(context,owner,delta,cursor)
def changed_release(context:Family.Context(),owner:changed_owner()) -> Family.Context():QP.release_context(~Family.Context())(context,owner)
def changed_parameter_type() -> Data:RP.Param<Family.Context(),changed_owner(),changed_view(),changed_delta(),changed_validate,changed_prepare,changed_commit,changed_release>
def changed_converted(value:RP.Param<Family.Context(),changed_owner(),changed_view(),changed_delta(),QP.validate_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.changed()),QP.prepare_context(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.changed()),QP.commit_context(~Family.Context()),QP.release_context(~Family.Context())>) -> changed_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def changed_parameter() -> changed_parameter_type():changed_converted(QP.from_observable(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Unit & Logical.Ops(Logical.Frame()),~Projection.Product<Unit,Logical.Value()>,~Logical.changed()))
def changed_initialize(context:Family.Context(),_:RP.RegistrationFacts) -> Family.Context() & (changed_owner() & changed_parameter_type()):(context,(Unit{},changed_parameter()))
def ping_owner() -> Type:SP.EventOwner<T.MotionSchema,F.Store(),F.Resources(),E.Publication,E.event_type(),Family.Family,Unit,Family.take_ping,Family.put_ping>
def ping_view() -> Data:SP.EventView<T.MotionSchema,E.event_type()>
def ping_delta() -> Type:Nat
def ping_validate(context:Family.Context(),owner:ping_owner()) -> Family.Context() & (ping_owner() & Bool):SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration())(context,owner)
def ping_prepare(context:Family.Context(),+cursor:U32,owner:ping_owner()) -> Family.Context() & (ping_owner() & (ping_view() & ping_delta())):SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration())(context,cursor,owner)
def ping_commit(context:Family.Context(),owner:ping_owner(),delta:ping_delta(),+cursor:U32) -> Family.Context() & ping_owner():SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)(context,owner,delta,cursor)
def ping_release(context:Family.Context(),owner:ping_owner()) -> Family.Context():SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)(context,owner)
def ping_parameter_type() -> Data:RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),ping_validate,ping_prepare,ping_commit,ping_release>
def ping_converted(value:RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)>) -> ping_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def ping_parameter() -> ping_parameter_type():ping_converted(SP.event_param(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,Family.ping_declaration()))
def ping_initialized(returned:Family.Context() & (ping_owner() & RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)>)) -> Family.Context() & (ping_owner() & ping_parameter_type()):
  match returned:
    case (context,(owner,RP.Param{access})):(context,(owner,RP.Param{access}))
def ping_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (ping_owner() & ping_parameter_type()):ping_initialized(SP.initialize_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration(),context,facts))
def removed_owner() -> Type:SP.EventOwner<T.MotionSchema,F.Store(),F.Resources(),E.Publication,E.event_type(),Family.Family,Unit,Family.take_removed,Family.put_removed>
def removed_view() -> Data:SP.EventView<T.MotionSchema,E.event_type()>
def removed_delta() -> Type:Nat
def removed_validate(context:Family.Context(),owner:removed_owner()) -> Family.Context() & (removed_owner() & Bool):SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration())(context,owner)
def removed_prepare(context:Family.Context(),+cursor:U32,owner:removed_owner()) -> Family.Context() & (removed_owner() & (removed_view() & removed_delta())):SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration())(context,cursor,owner)
def removed_commit(context:Family.Context(),owner:removed_owner(),delta:removed_delta(),+cursor:U32) -> Family.Context() & removed_owner():SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed)(context,owner,delta,cursor)
def removed_release(context:Family.Context(),owner:removed_owner()) -> Family.Context():SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed)(context,owner)
def removed_parameter_type() -> Data:RP.Param<Family.Context(),removed_owner(),removed_view(),removed_delta(),removed_validate,removed_prepare,removed_commit,removed_release>
def removed_converted(value:RP.Param<Family.Context(),removed_owner(),removed_view(),removed_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed)>) -> removed_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def removed_parameter() -> removed_parameter_type():removed_converted(SP.event_param(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,Family.removed_declaration()))
def removed_initialized(returned:Family.Context() & (removed_owner() & RP.Param<Family.Context(),removed_owner(),removed_view(),removed_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed)>)) -> Family.Context() & (removed_owner() & removed_parameter_type()):
  match returned:
    case (context,(owner,RP.Param{access})):(context,(owner,RP.Param{access}))
def removed_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (removed_owner() & removed_parameter_type()):removed_initialized(SP.initialize_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_removed,~Family.put_removed,~Family.removed_declaration(),context,facts))
def despawned_owner() -> Type:SP.EventOwner<T.MotionSchema,F.Store(),F.Resources(),E.Publication,E.event_type(),Family.Family,Unit,Family.take_despawned,Family.put_despawned>
def despawned_view() -> Data:SP.EventView<T.MotionSchema,E.event_type()>
def despawned_delta() -> Type:Nat
def despawned_validate(context:Family.Context(),owner:despawned_owner()) -> Family.Context() & (despawned_owner() & Bool):SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration())(context,owner)
def despawned_prepare(context:Family.Context(),+cursor:U32,owner:despawned_owner()) -> Family.Context() & (despawned_owner() & (despawned_view() & despawned_delta())):SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration())(context,cursor,owner)
def despawned_commit(context:Family.Context(),owner:despawned_owner(),delta:despawned_delta(),+cursor:U32) -> Family.Context() & despawned_owner():SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned)(context,owner,delta,cursor)
def despawned_release(context:Family.Context(),owner:despawned_owner()) -> Family.Context():SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned)(context,owner)
def despawned_parameter_type() -> Data:RP.Param<Family.Context(),despawned_owner(),despawned_view(),despawned_delta(),despawned_validate,despawned_prepare,despawned_commit,despawned_release>
def despawned_converted(value:RP.Param<Family.Context(),despawned_owner(),despawned_view(),despawned_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned)>) -> despawned_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def despawned_parameter() -> despawned_parameter_type():despawned_converted(SP.event_param(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,Family.despawned_declaration()))
def despawned_initialized(returned:Family.Context() & (despawned_owner() & RP.Param<Family.Context(),despawned_owner(),despawned_view(),despawned_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned)>)) -> Family.Context() & (despawned_owner() & despawned_parameter_type()):
  match returned:
    case (context,(owner,RP.Param{access})):(context,(owner,RP.Param{access}))
def despawned_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (despawned_owner() & despawned_parameter_type()):despawned_initialized(SP.initialize_event(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~E.event_type(),~Family.Family,~Unit,~Family.take_despawned,~Family.put_despawned,~Family.despawned_declaration(),context,facts))
def tail_events_owner() -> Type:removed_owner() & despawned_owner()
def tail_events_view() -> Data:RP.ViewPair<removed_view(),despawned_view()>
def tail_events_delta() -> Type:removed_delta() & despawned_delta()
def tail_events_validate(context:Family.Context(),owner:tail_events_owner()) -> Family.Context() & (tail_events_owner() & Bool):
  RP.pair_validate_fn(~Family.Context(),~removed_owner(),~despawned_owner(),~removed_validate,~despawned_validate,context,owner)
def tail_events_prepare(context:Family.Context(),+cursor:U32,owner:tail_events_owner()) -> Family.Context() & (tail_events_owner() & (tail_events_view() & tail_events_delta())):
  RP.pair_prepare_fn(~Family.Context(),~removed_owner(),~despawned_owner(),~removed_view(),~despawned_view(),~removed_delta(),~despawned_delta(),~removed_prepare,~despawned_prepare,context,cursor,owner)
def tail_events_commit(context:Family.Context(),owner:tail_events_owner(),delta:tail_events_delta(),+cursor:U32) -> Family.Context() & tail_events_owner():
  RP.pair_commit_fn(~Family.Context(),~removed_owner(),~despawned_owner(),~removed_delta(),~despawned_delta(),~removed_commit,~despawned_commit,context,owner,delta,cursor)
def tail_events_release(context:Family.Context(),owner:tail_events_owner()) -> Family.Context():
  RP.pair_release_fn(~Family.Context(),~removed_owner(),~despawned_owner(),~removed_release,~despawned_release,context,owner)
def tail_events_parameter_type() -> Data:RP.Param<Family.Context(),tail_events_owner(),tail_events_view(),tail_events_delta(),tail_events_validate,tail_events_prepare,tail_events_commit,tail_events_release>
def tail_events_pair(left:removed_parameter_type(),right:despawned_parameter_type()) -> tail_events_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def tail_events_parameter() -> tail_events_parameter_type():tail_events_pair(removed_parameter(),despawned_parameter())
def tail_events_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (tail_events_owner() & tail_events_parameter_type()):
  RP.initialize_pair(~Family.Context(),~RP.RegistrationFacts,~removed_owner(),~removed_parameter_type(),~despawned_owner(),~despawned_parameter_type(),~tail_events_parameter_type(),~removed_initialize,~despawned_initialize,~tail_events_pair,context,facts)
def events_owner() -> Type:ping_owner() & tail_events_owner()
def events_view() -> Data:RP.ViewPair<ping_view(),tail_events_view()>
def events_delta() -> Type:ping_delta() & tail_events_delta()
def events_validate(context:Family.Context(),owner:events_owner()) -> Family.Context() & (events_owner() & Bool):
  RP.pair_validate_fn(~Family.Context(),~ping_owner(),~tail_events_owner(),~ping_validate,~tail_events_validate,context,owner)
def events_prepare(context:Family.Context(),+cursor:U32,owner:events_owner()) -> Family.Context() & (events_owner() & (events_view() & events_delta())):
  RP.pair_prepare_fn(~Family.Context(),~ping_owner(),~tail_events_owner(),~ping_view(),~tail_events_view(),~ping_delta(),~tail_events_delta(),~ping_prepare,~tail_events_prepare,context,cursor,owner)
def events_commit(context:Family.Context(),owner:events_owner(),delta:events_delta(),+cursor:U32) -> Family.Context() & events_owner():
  RP.pair_commit_fn(~Family.Context(),~ping_owner(),~tail_events_owner(),~ping_delta(),~tail_events_delta(),~ping_commit,~tail_events_commit,context,owner,delta,cursor)
def events_release(context:Family.Context(),owner:events_owner()) -> Family.Context():
  RP.pair_release_fn(~Family.Context(),~ping_owner(),~tail_events_owner(),~ping_release,~tail_events_release,context,owner)
def events_parameter_type() -> Data:RP.Param<Family.Context(),events_owner(),events_view(),events_delta(),events_validate,events_prepare,events_commit,events_release>
def events_pair(left:ping_parameter_type(),right:tail_events_parameter_type()) -> events_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def events_parameter() -> events_parameter_type():events_pair(ping_parameter(),tail_events_parameter())
def events_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (events_owner() & events_parameter_type()):
  RP.initialize_pair(~Family.Context(),~RP.RegistrationFacts,~ping_owner(),~ping_parameter_type(),~tail_events_owner(),~tail_events_parameter_type(),~events_parameter_type(),~ping_initialize,~tail_events_initialize,~events_pair,context,facts)
def query_tail_owner() -> Type:changed_owner() & events_owner()
def query_tail_view() -> Data:RP.ViewPair<changed_view(),events_view()>
def query_tail_delta() -> Type:changed_delta() & events_delta()
def query_tail_validate(context:Family.Context(),owner:query_tail_owner()) -> Family.Context() & (query_tail_owner() & Bool):
  RP.pair_validate_fn(~Family.Context(),~changed_owner(),~events_owner(),~changed_validate,~events_validate,context,owner)
def query_tail_prepare(context:Family.Context(),+cursor:U32,owner:query_tail_owner()) -> Family.Context() & (query_tail_owner() & (query_tail_view() & query_tail_delta())):
  RP.pair_prepare_fn(~Family.Context(),~changed_owner(),~events_owner(),~changed_view(),~events_view(),~changed_delta(),~events_delta(),~changed_prepare,~events_prepare,context,cursor,owner)
def query_tail_commit(context:Family.Context(),owner:query_tail_owner(),delta:query_tail_delta(),+cursor:U32) -> Family.Context() & query_tail_owner():
  RP.pair_commit_fn(~Family.Context(),~changed_owner(),~events_owner(),~changed_delta(),~events_delta(),~changed_commit,~events_commit,context,owner,delta,cursor)
def query_tail_release(context:Family.Context(),owner:query_tail_owner()) -> Family.Context():
  RP.pair_release_fn(~Family.Context(),~changed_owner(),~events_owner(),~changed_release,~events_release,context,owner)
def query_tail_parameter_type() -> Data:RP.Param<Family.Context(),query_tail_owner(),query_tail_view(),query_tail_delta(),query_tail_validate,query_tail_prepare,query_tail_commit,query_tail_release>
def query_tail_pair(left:changed_parameter_type(),right:events_parameter_type()) -> query_tail_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def query_tail_parameter() -> query_tail_parameter_type():query_tail_pair(changed_parameter(),events_parameter())
def query_tail_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (query_tail_owner() & query_tail_parameter_type()):
  RP.initialize_pair(~Family.Context(),~RP.RegistrationFacts,~changed_owner(),~changed_parameter_type(),~events_owner(),~events_parameter_type(),~query_tail_parameter_type(),~changed_initialize,~events_initialize,~query_tail_pair,context,facts)
def query_added_owner() -> Type:added_owner() & query_tail_owner()
def query_added_view() -> Data:RP.ViewPair<added_view(),query_tail_view()>
def query_added_delta() -> Type:added_delta() & query_tail_delta()
def query_added_validate(context:Family.Context(),owner:query_added_owner()) -> Family.Context() & (query_added_owner() & Bool):
  RP.pair_validate_fn(~Family.Context(),~added_owner(),~query_tail_owner(),~added_validate,~query_tail_validate,context,owner)
def query_added_prepare(context:Family.Context(),+cursor:U32,owner:query_added_owner()) -> Family.Context() & (query_added_owner() & (query_added_view() & query_added_delta())):
  RP.pair_prepare_fn(~Family.Context(),~added_owner(),~query_tail_owner(),~added_view(),~query_tail_view(),~added_delta(),~query_tail_delta(),~added_prepare,~query_tail_prepare,context,cursor,owner)
def query_added_commit(context:Family.Context(),owner:query_added_owner(),delta:query_added_delta(),+cursor:U32) -> Family.Context() & query_added_owner():
  RP.pair_commit_fn(~Family.Context(),~added_owner(),~query_tail_owner(),~added_delta(),~query_tail_delta(),~added_commit,~query_tail_commit,context,owner,delta,cursor)
def query_added_release(context:Family.Context(),owner:query_added_owner()) -> Family.Context():
  RP.pair_release_fn(~Family.Context(),~added_owner(),~query_tail_owner(),~added_release,~query_tail_release,context,owner)
def query_added_parameter_type() -> Data:RP.Param<Family.Context(),query_added_owner(),query_added_view(),query_added_delta(),query_added_validate,query_added_prepare,query_added_commit,query_added_release>
def query_added_pair(left:added_parameter_type(),right:query_tail_parameter_type()) -> query_added_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def query_added_parameter() -> query_added_parameter_type():query_added_pair(added_parameter(),query_tail_parameter())
def query_added_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (query_added_owner() & query_added_parameter_type()):
  RP.initialize_pair(~Family.Context(),~RP.RegistrationFacts,~added_owner(),~added_parameter_type(),~query_tail_owner(),~query_tail_parameter_type(),~query_added_parameter_type(),~added_initialize,~query_tail_initialize,~query_added_pair,context,facts)
def all_owner() -> Type:allrows_owner() & query_added_owner()
def all_raw_view() -> Data:RP.ViewPair<allrows_view(),query_added_view()>
type PreparedView is Data:
  PreparedView{value:all_raw_view(),queryCursor:U32,readThroughPing:Nat,readThroughRemoved:Nat,readThroughDespawned:Nat,runningContext:Doc.Doc}
def all_view() -> Data:PreparedView
def all_delta() -> Type:allrows_delta() & query_added_delta()
def all_validate(context:Family.Context(),owner:all_owner()) -> Family.Context() & (all_owner() & Bool):
  RP.pair_validate_fn(~Family.Context(),~allrows_owner(),~query_added_owner(),~allrows_validate,~query_added_validate,context,owner)
def all_capture_context(view:all_raw_view(),cursor:U32,owner:all_owner(),+ping:Nat,+removed:Nat,+despawned:Nat,observed:Family.Context() & Doc.Doc) -> Family.Context() & (all_owner() & (all_view() & all_delta())):
  match observed:
    case (context,text):(context,(owner,(PreparedView{view,cursor,ping,removed,despawned,text},(Unit{},(Unit{},(Unit{},(ping,(removed,despawned))))))))
def all_capture(view:all_raw_view(),+cursor:U32,owner:all_owner(),delta:all_delta(),observed:Family.Context() & Doc.Doc) -> Family.Context() & (all_owner() & (all_view() & all_delta())):
  match delta:
    case (Unit{},(Unit{},(Unit{},(ping,(removed,despawned))))):all_capture_context(view,cursor,owner,ping,removed,despawned,observed)
def all_prepared(cursor:U32,returned:Family.Context() & (all_owner() & (all_raw_view() & all_delta()))) -> Family.Context() & (all_owner() & (all_view() & all_delta())):
  match returned:
    case (context,(owner,(view,delta))):all_capture(view,cursor,owner,delta,RuntimeObserve.doc_context(context))
def all_prepare(context:Family.Context(),+cursor:U32,owner:all_owner()) -> Family.Context() & (all_owner() & (all_view() & all_delta())):
  all_prepared(cursor,RP.pair_prepare_fn(~Family.Context(),~allrows_owner(),~query_added_owner(),~allrows_view(),~query_added_view(),~allrows_delta(),~query_added_delta(),~allrows_prepare,~query_added_prepare,context,cursor,owner))
def all_commit(context:Family.Context(),owner:all_owner(),delta:all_delta(),+cursor:U32) -> Family.Context() & all_owner():
  RP.pair_commit_fn(~Family.Context(),~allrows_owner(),~query_added_owner(),~allrows_delta(),~query_added_delta(),~allrows_commit,~query_added_commit,context,owner,delta,cursor)
def all_release(context:Family.Context(),owner:all_owner()) -> Family.Context():
  RP.pair_release_fn(~Family.Context(),~allrows_owner(),~query_added_owner(),~allrows_release,~query_added_release,context,owner)
def all_parameter_type() -> Data:RP.Param<Family.Context(),all_owner(),all_view(),all_delta(),all_validate,all_prepare,all_commit,all_release>
def all_pair(left:allrows_parameter_type(),right:query_added_parameter_type()) -> all_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def all_parameter() -> all_parameter_type():all_pair(allrows_parameter(),query_added_parameter())
def all_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (all_owner() & all_parameter_type()):
  RP.initialize_pair(~Family.Context(),~RP.RegistrationFacts,~allrows_owner(),~allrows_parameter_type(),~query_added_owner(),~query_added_parameter_type(),~all_parameter_type(),~allrows_initialize,~query_added_initialize,~all_pair,context,facts)
