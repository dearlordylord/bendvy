import Base
import /tmp/bendvy-failedtxn-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-family.bend as Family
import health-parameters.bend as P
import health-callbacks.bend as C
import health-grants.bend as G
import health-tx-observe.bend as Inspect
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/ordinary-reader-system.bend as O
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/system.bend as Sys
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/transaction.bend as Tx
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/event-notice-runtime.bend as Mixed
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/internal/relation-failures/domains.bend as Domain

type Args is Type:
  Args{target:W.Handle<T.HealthSchema>,iteration:U32,twice:Bool,prime:Bool,outcome:Tx.Outcome<U32>,capture:U32}
type Read is Type:
  Read{callback:C.Output<P.ping_view()>,facts:Inspect.Facts}
def Ops(H:Type) -> Type:C.Ops<H,E.event_type()> & (H -> H & Inspect.Facts)
def grant() -> Ops(G.Owner()):(G.ops(),Inspect.observe)
def callback_caps(~H:Type,caps:Ops(H)) -> C.Ops<H,E.event_type()>:
  match caps:
    case (caps,_):caps
def inspect(~H:Type,caps:Ops(H)) -> H -> H & Inspect.Facts:
  match caps:
    case (_,inspect):inspect
def inspected(~H:Type,outcome:Tx.Outcome<U32>,callback:C.Output<P.ping_view()>,observed:H & Inspect.Facts) -> H & (Tx.Outcome<U32> & Read):
  match observed:
    case (owner,facts):(owner,(outcome,Read{callback,facts}))
def completed(~H:Type,~caps:Ops(H),returned:H & C.Output<P.ping_view()>) -> H & (Tx.Outcome<U32> & Read):
  match returned:
    case (owner,C.Output{+outcome,reading,reservation,payload,writes,ledger,rejected,error,lookup}):inspected(~H,outcome,C.Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,lookup},inspect(~H,caps)(owner))
def body(~H:Type,~caps:Ops(H),input:P.ping_view() & Args,owner:H) -> H & (Tx.Outcome<U32> & Read):
  match input:
    case (view,Args{target,iteration,twice,prime,outcome,capture}):completed(~H,~caps,C.body(~H,~E.event_type(),~P.ping_view(),~callback_caps(~H,caps),~E.ping,C.Args{target,iteration,capture,twice,prime,outcome,view},owner))
def classify(_:E.event_type()) -> Maybe<Domain.DescriptorKey<T.HealthSchema>>:None{}
def Meta() -> Type:Mixed.State<T.HealthSchema,Nat,Family.Family,Unit> & Nat
def Invocation() -> Type:O.Invocation<Meta(),P.ping_owner(),P.ping_parameter_type(),Unit,Args>
def Envelope() -> Type:O.Envelope<Meta(),P.ping_owner(),P.ping_parameter_type(),Unit,U32,Read>
def runner() -> F.World() -> Invocation() -> Sys.Outcome<F.World(),Empty,Envelope()>:O.shared_runner(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~U32,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(),~Family.sync,~classify)
def Registry() -> Type:Sys.Registry<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),Invocation(),Empty,Envelope(),runner()>
def Provider() -> Type:O.Provider<Registry(),P.ping_owner(),P.ping_parameter_type(),Unit>
def Definition() -> Type:O.Definition<Family.Context(),Provider(),P.ping_parameter_type(),Unit>
def define(context:Family.Context(),name:String) -> Definition():O.define_mixed(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~U32,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(),~Family.sync,~classify,~P.writer_initialize,P.writer_parameter(),Unit{},context,name)
def Run() -> Type:O.RunResult<Family.Context(),Provider(),Args,U32,Read>
def run(provider:Provider(),context:Family.Context(),args:Args) -> Run():O.run_mixed(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family.Family,~Unit,~P.ping_owner(),~P.ping_view(),~P.ping_delta(),~Args,~Unit,~U32,~Read,~P.ping_validate,~P.ping_prepare,~P.ping_commit,~P.ping_release,~Ops,~body,~grant(),~Family.sync,~classify,provider,context,args)
