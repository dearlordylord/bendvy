import Base
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-family.bend as Family
import motion-parameters.bend as P
import ../private/src/ecs/ordinary-reader-system.bend as O
import ../private/src/ecs/system.bend as Sys
import ../private/src/ecs/transaction.bend as Tx
import ../private/src/ecs/event-notice-runtime.bend as Mixed
import ../private/src/ecs/internal/relation-failures/domains.bend as Domain

type Args is Data:
  Args{who:U32,phase:U32,iteration:U32}
type Read is Data:
  Read{args:Args,view:P.all_view()}
def Ops(H:Type) -> Type:Unit
def grant(~H:Type) -> Unit:Unit{}
def body(~H:Type,~caps:Ops(H),input:P.all_view() & Args,owner:H) -> H & (Tx.Outcome<Unit> & Read):
  match input:
    case (view,args):(owner,(Tx.Success{},Read{args,view}))
def classify(_:E.event_type()) -> Maybe<Domain.DescriptorKey<T.MotionSchema>>:None{}
def Meta() -> Type:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit> & Nat
def Invocation() -> Type:O.Invocation<Meta(),P.all_owner(),P.all_parameter_type(),Unit,Args>
def Envelope() -> Type:O.Envelope<Meta(),P.all_owner(),P.all_parameter_type(),Unit,Unit,Read>
def runner() -> F.World() -> Invocation() -> Sys.Outcome<F.World(),Empty,Envelope()>:O.shared_runner(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify)
def Registry() -> Type:Sys.Registry<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Invocation(),Empty,Envelope(),runner()>
def Provider() -> Type:O.Provider<Registry(),P.all_owner(),P.all_parameter_type(),Unit>
def Definition() -> Type:O.Definition<Family.Context(),Provider(),P.all_parameter_type(),Unit>
def define(context:Family.Context(),name:String) -> Definition():O.define_mixed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify,~P.all_initialize,P.all_parameter(),Unit{},context,name)
def Run() -> Type:O.RunResult<Family.Context(),Provider(),Args,Unit,Read>
def run(provider:Provider(),context:Family.Context(),args:Args) -> Run():O.run_mixed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify,provider,context,args)
