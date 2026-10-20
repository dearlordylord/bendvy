import Base
import ../../../../src/ecs/change-tick.bend as Tick
import motion-access.bend as Access
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-family.bend as Family
import ../../../../src/ecs/reader-parameter.bend as RP
import ../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
def ping_owner() -> Type:SP.EventOwner<T.MotionSchema,F.Store(),F.Resources(),Nat,E.event_type(),Family.Family,Unit,Family.take_ping,Family.put_ping>
def ping_view() -> Data:SP.EventView<T.MotionSchema,E.event_type()>
def ping_delta() -> Type:Nat
def ping_validate(context:Family.Context(),owner:ping_owner()) -> Family.Context() & (ping_owner() & Bool):SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration())(context,owner)
def ping_prepare(context:Family.Context(),+cursor:Maybe<&2,Tick.Tick>,owner:ping_owner()) -> Family.Context() & (ping_owner() & (ping_view() & ping_delta())):SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration())(context,cursor,owner)
def ping_commit(context:Family.Context(),owner:ping_owner(),delta:ping_delta(),+cursor:Tick.Tick) -> Family.Context() & ping_owner():SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)(context,owner,delta,cursor)
def ping_release(context:Family.Context(),owner:ping_owner()) -> Family.Context():SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)(context,owner)
def ping_parameter_type() -> Data:RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),ping_validate,ping_prepare,ping_commit,ping_release>
def ping_converted(value:RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)>) -> ping_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{access}
def ping_parameter() -> ping_parameter_type():ping_converted(SP.event_param(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,Family.ping_declaration()))
def ping_initialized(returned:Family.Context() & (ping_owner() & RP.Param<Family.Context(),ping_owner(),ping_view(),ping_delta(),SP.validate_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.prepare_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration()),SP.commit_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping),SP.release_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping)>)) -> Family.Context() & (ping_owner() & ping_parameter_type()):
  match returned:
    case (context,(owner,RP.Param{access})):(context,(owner,RP.Param{access}))
def ping_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (ping_owner() & ping_parameter_type()):ping_initialized(SP.initialize_event(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~E.event_type(),~Family.Family,~Unit,~Family.take_ping,~Family.put_ping,~Family.ping_declaration(),context,facts))

def writer_converted(value:ping_parameter_type()) -> ping_parameter_type():
  match value:
    case RP.Param{access}:RP.Param{List.append(&2,String,access,Access.access())}
def writer_parameter() -> ping_parameter_type():writer_converted(ping_parameter())
def writer_initialized(value:Family.Context() & (ping_owner() & ping_parameter_type())) -> Family.Context() & (ping_owner() & ping_parameter_type()):
  match value:
    case (context,(owner,param)):(context,(owner,writer_converted(param)))
def writer_initialize(context:Family.Context(),facts:RP.RegistrationFacts) -> Family.Context() & (ping_owner() & ping_parameter_type()):writer_initialized(ping_initialize(context,facts))
