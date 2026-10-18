import Base
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-family.bend as Family
import health-reader.bend as Reader
import health-callbacks.bend as C
import health-grants.bend as G
import health-tx-observe.bend as Inspect
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/ordinary-reader-system.bend as O
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/event-family-routing.bend as Route

def Meta() -> Type:Mixed.State<T.HealthSchema,Nat,Family.Family,Unit>
type State is Type:
  A{capture:Array<U32>}
  B{capture:Array<U32>,reader:Reader.Provider()}
type Args is Type:
  Args{meta:Meta(),tick:Nat,target:W.Handle<T.HealthSchema>,iteration:U32,prime:Bool,outcome:Tx.Outcome<U32>}
type Call is Type:
  ACall{outcome:Tx.Outcome<U32>,output:C.Output<Unit>,facts:Inspect.Facts}
  BCall{status:U32,error:Maybe<&2,U32>,output:Maybe<&1,Reader.Read>}
type Returned is Type:
  Returned{meta:Meta(),tick:Nat,call:Call}
def a_finished(capture:Array<U32>,meta:Meta(),tick:Nat,output:C.Output<Unit>,facts:Inspect.Facts,result:Tx.Returned<F.World(),U32>) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match result:
    case Tx.Returned{world,+outcome}:Local.Succeeded{world,A{capture},Returned{meta,tick,ACall{outcome,output,facts}}}
def a_observed(capture:Array<U32>,meta:Meta(),tick:Nat,outcome:Tx.Outcome<U32>,output:C.Output<Unit>,observed:G.Owner() & Inspect.Facts) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match observed:
    case (owner,facts):a_finished(capture,meta,tick,output,facts,Cmd.tx_finish(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~U32,owner,outcome))
def a_returned(capture:Array<U32>,meta:Meta(),tick:Nat,result:G.Owner() & C.Output<Unit>) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match result:
    case (owner,C.Output{+outcome,reading,reservation,payload,writes,ledger,rejected,error,lookup}):a_observed(capture,meta,tick,outcome,C.Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,lookup},Inspect.observe(owner))
def a_count(world:F.World(),meta:Meta(),tick:Nat,target:W.Handle<T.HealthSchema>,iteration:U32,prime:Bool,outcome:Tx.Outcome<U32>,observed:Array<U32> & U32) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match observed:
    case (capture,+count):a_returned(Array.set(U32,capture,0,U32.add(count,1)),meta,tick,C.body(~G.Owner(),~E.event_type(),~Unit,~G.ops(),~E.ping,C.Args{target,iteration,U32.add(count,1),False{},prime,outcome,Unit{}},Tx.begin(~F.World(),~E.event_type(),world)))
def b_context(capture:Array<U32>,reader:Reader.Provider(),status:U32,error:Maybe<&2,U32>,output:Maybe<&1,Reader.Read>,context:Family.Context()) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match context:
    case Route.Runtime{world,meta,tick}:Local.Succeeded{world,B{capture,reader},Returned{meta,tick,BCall{status,error,output}}}
def b_bumped(reader:Reader.Provider(),status:U32,error:Maybe<&2,U32>,output:Reader.Read,context:Family.Context(),observed:Array<U32> & U32) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match observed:
    case (capture,count):b_context(Array.set(U32,capture,0,U32.add(count,1)),reader,status,error,Some{output},context)
def b_returned(capture:Array<U32>,result:Reader.Run()) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match result:
    case O.RunCompleted{context,provider,output}:b_bumped(provider,0,None{},output,context,Array.get(U32,capture,0))
    case O.RunFailed{context,provider,error,output}:b_bumped(provider,1,Some{error},output,context,Array.get(U32,capture,0))
    case O.RunInvalidReader{context,provider}:b_context(capture,provider,2,None{},None{},context)
    case O.RunRegistrationRejected{context,provider,_}:b_context(capture,provider,3,None{},None{},context)
    case O.RunSkipped{context,provider}:b_context(capture,provider,4,None{},None{},context)
def b_count(world:F.World(),meta:Meta(),tick:Nat,reader:Reader.Provider(),target:W.Handle<T.HealthSchema>,iteration:U32,prime:Bool,outcome:Tx.Outcome<U32>,observed:Array<U32> & U32) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match observed:
    case (capture,+count):b_returned(capture,Reader.run(reader,Route.Runtime{world,meta,tick},Reader.Args{target,iteration,True{},prime,outcome,U32.add(count,1)}))
def runner(world:F.World(),local:State,args:Args) -> Local.Outcome<F.World(),State,Empty,Returned>:
  match local args:
    case A{capture} Args{meta,tick,target,iteration,prime,outcome}:a_count(world,meta,tick,target,iteration,prime,outcome,Array.get(U32,capture,0))
    case B{capture,reader} Args{meta,tick,target,iteration,prime,outcome}:b_count(world,meta,tick,reader,target,iteration,prime,outcome,Array.get(U32,capture,0))
def Instance() -> Type:Local.Instance<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),State,Args,Empty,Returned,runner>
