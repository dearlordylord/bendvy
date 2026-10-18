import Base
import health.bend as F
import ../../../../dense-runtime-v1/types.bend as T
import health-events.bend as E
import health-family.bend as Family
import health-parameters.bend as P
import ../../../../../../../src/ecs/ordinary-reader-system.bend as O
import ../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../src/ecs/internal/relation-failures/domains.bend as Domain

type Args is Data:
  Args{phase:U32,iteration:U32}
type Read is Data:
  Read{args:Args,view:P.ping_view()}
def Ops(H:Type) -> Type:Unit
def grant(~H:Type) -> Unit:Unit{}
def body(~H:Type,~caps:Ops(H),input:P.ping_view() & Args,owner:H) -> H & (Tx.Outcome<Unit> & Read):
  match input:
    case (view,args):(owner,(Tx.Success{},Read{args,view}))
def classify(_:E.event_type()) -> Maybe<Domain.DescriptorKey<T.HealthSchema>>:None{}
def Meta() -> Type:Mixed.State<T.HealthSchema,Nat,Family.Family,Unit> & Nat
def Invocation() -> Type:O.Invocation<Meta(),P.ping_owner(),P.ping_parameter_type(),Unit,Args>
def Envelope() -> Type:O.Envelope<Meta(),P.ping_owner(),P.ping_parameter_type(),Unit,Unit,Read>
def runner() -> F.World() -> Invocation() -> Sys.Outcome<F.World(),Empty,Envelope()>:O.shared_runner(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~Unit,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify)
def Registry() -> Type:Sys.Registry<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),Invocation(),Empty,Envelope(),runner()>
def Provider() -> Type:O.Provider<Registry(),P.ping_owner(),P.ping_parameter_type(),Unit>
def Definition() -> Type:O.Definition<Family.Context(),Provider(),P.ping_parameter_type(),Unit>
def define(context:Family.Context(),name:String) -> Definition():O.define_mixed(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~Unit,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify,~P.ping_initialize,P.ping_parameter(),Unit{},context,name)
def Run() -> Type:O.RunResult<Family.Context(),Provider(),Args,Unit,Read>
def run(provider:Provider(),context:Family.Context(),args:Args) -> Run():O.run_mixed(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~Unit,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(~Tx.Tx<F.World(),E.event_type()>),~Family.sync,~classify,provider,context,args)
