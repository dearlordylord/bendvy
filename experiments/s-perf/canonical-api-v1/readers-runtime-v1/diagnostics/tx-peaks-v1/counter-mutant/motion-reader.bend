import Base
import tx-metrics.bend as Metrics
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-family.bend as Family
import motion-parameters.bend as P
import ../../../../../../../src/ecs/ordinary-reader-system.bend as O
import ../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../src/ecs/internal/relation-failures/domains.bend as Domain

type Args is Data:
  Args{who:U32,phase:U32,iteration:U32}
type Read is Data:
  Read{args:Args,view:P.all_view(),sample:Metrics.Sample}
type CaptureOps<H:Type> is Type:
  Capture{observe:H -> H & Metrics.Sample}
def Ops(H:Type) -> Type:CaptureOps<H>
def grant() -> Ops(Tx.Tx<F.World(),E.event_type()>):Capture{tx=>Metrics.observe(~F.World(),~E.event_type(),"reader",tx)}
def captured(~H:Type,args:Args,view:P.all_view(),observed:H & Metrics.Sample) -> H & (Tx.Outcome<Unit> & Read):
  match observed:
    case (owner,sample):(owner,(Tx.Success{},Read{args,view,sample}))
def observed(~H:Type,caps:Ops(H),owner:H) -> H & Metrics.Sample:
  match caps:
    case Capture{observe}:observe(owner)
def body(~H:Type,~caps:Ops(H),input:P.all_view() & Args,owner:H) -> H & (Tx.Outcome<Unit> & Read):
  match input:
    case (view,args):captured(~H,args,view,observed(~H,caps,owner))
def classify(_:E.event_type()) -> Maybe<Domain.DescriptorKey<T.MotionSchema>>:None{}
def Meta() -> Type:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit> & Nat
def Invocation() -> Type:O.Invocation<Meta(),P.all_owner(),P.all_parameter_type(),Unit,Args>
def Envelope() -> Type:O.Envelope<Meta(),P.all_owner(),P.all_parameter_type(),Unit,Unit,Read>
def runner() -> F.World() -> Invocation() -> Sys.Outcome<F.World(),Empty,Envelope()>:O.shared_runner(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(),~Family.sync,~classify)
def Registry() -> Type:Sys.Registry<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Invocation(),Empty,Envelope(),runner()>
def Provider() -> Type:O.Provider<Registry(),P.all_owner(),P.all_parameter_type(),Unit>
def Definition() -> Type:O.Definition<Family.Context(),Provider(),P.all_parameter_type(),Unit>
def define(context:Family.Context(),name:String) -> Definition():O.define_mixed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(),~Family.sync,~classify,~P.all_initialize,P.all_parameter(),Unit{},context,name)
def Run() -> Type:O.RunResult<Family.Context(),Provider(),Args,Unit,Read>
def run(provider:Provider(),context:Family.Context(),args:Args) -> Run():O.run_mixed(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~P.all_owner(),~P.all_view(),~P.all_delta(),~Args,~Unit,~Unit,~Read,~P.all_validate,~P.all_prepare,~P.all_commit,~P.all_release,~Ops,~body,~grant(),~Family.sync,~classify,provider,context,args)
