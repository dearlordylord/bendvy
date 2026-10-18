import Base
import ../private/experiments/public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import schema.bend as S
import body.bend as Body
import observe.bend as Observe
import sampler.bend as Sampler
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/local.bend as Local
import ../private/src/ecs/capabilities.bend as Cap
import ../private/src/ecs/bundle-insert-adapter.bend as Adapter
import ../private/src/ecs/bundle-batch.bend as Batch
import ../private/src/ecs/transaction.bend as T

type View is Data:View{text:String,reports:List<&2,Sampler.Sample>}
type State is Type:State{token:Array<U32>,returned:List<Array<U32>>,before:String,after:String,reports:List<&2,Sampler.Sample>}
def initial(_:Unit) -> State:State{ALeaf{99},[],"","",[]}
def unpack_cons(packet:S.Packet,rest:List<Array<U32>>) -> List<Array<U32>>:S.unpack(packet) <> rest
def unpack(packets:List<S.Packet>) -> List<Array<U32>>:
  match packets:
    case []:[]
    case packet <> tail:unpack_cons(packet,unpack(tail))
def finish_success(token:Array<U32>,returned:List<Array<U32>>,before:String,reports:List<&2,Sampler.Sample>,observed:S.World() & String) -> Local.Outcome<S.World(),State,Unit,Unit>:
  match observed:
    case (world,after):Local.Succeeded{world,State{token,returned,before,after,reports},Unit{}}
def finish_failure(token:Array<U32>,returned:List<Array<U32>>,before:String,reports:List<&2,Sampler.Sample>,error:Unit,observed:S.World() & String) -> Local.Outcome<S.World(),State,Unit,Unit>:
  match observed:
    case (world,after):Local.Failed{world,State{token,returned,before,after,reports},error}
def finished(token:Array<U32>,returned:List<Array<U32>>,before:String,prior:List<&2,Sampler.Sample>,result:Batch.Finished<S.Schema,S.Store(),Array<U32>,U32,S.Packet,Unit>) -> Local.Outcome<S.World(),State,Unit,Unit>:
  match result:
    case Batch.Committed{world,reports}:finish_success(token,returned,before,List.append(&2,Sampler.Sample,prior,reports),Observe.world(world))
    case Batch.Failed{world,packets,error,reports}:finish_failure(token,List.append(&1,Array<U32>,returned,unpack(packets)),before,List.append(&2,Sampler.Sample,prior,reports),error,Observe.world(world))
def observed(token:Array<U32>,returned:List<Array<U32>>,prior:List<&2,Sampler.Sample>,outcome:T.Outcome<Unit>,value:Batch.Batch<S.Schema,S.Store(),Array<U32>,U32,S.Packet> & String) -> Local.Outcome<S.World(),State,Unit,Unit>:
  match value:
    case (batch,before):finished(token,returned,before,prior,Batch.finish(~S.Schema,~S.Store(),~Array<U32>,~U32,~S.Packet,~Unit,~S.attempt,~S.recover,batch,outcome))
def body_returned(local:State,value:S.Owner() & Body.BodyResult) -> Local.Outcome<S.World(),State,Unit,Unit>:
  match local value:
    case State{token,returned,_,_,reports},(Adapter.Owner{batch,_},Body.BodyResult{outcome,refused}):observed(token,List.append(&1,Array<U32>,returned,refused),reports,outcome,Observe.batch(batch))
def runner(world:S.World(),local:State,fail:Bool) -> Local.Outcome<S.World(),State,Unit,Unit>:body_returned(local,Cap.invoke(~S.Ops,~Bool,~Body.BodyResult,~Body.run,~S.Owner(),~(Cap.ValueWrite{S.read,S.set},(Cap.Send{S.send},Cap.OwnedRequest{S.request})),fail,Adapter.Owner{Batch.Batch{Sampler.begin(~S.Schema,~S.Store(),~Array<U32>,~U32,world),[]},Unit{}}))
def Instance() -> Type:Local.Instance<S.Schema,S.Store(),Array<U32>,U32,State,Bool,Unit,Unit,runner>
def project_join(+before:String,+after:String,+reports:List<&2,Sampler.Sample>,observed:Array<U32> & String,owners:List<Array<U32>> & List<&2,String>) -> State & View:
  match observed owners:
    case (token,text),(returned,texts):(State{token,returned,before,after,reports},View{"token=" ++ text ++ "|returned=" ++ List.show(&2,String,x=>x,texts) ++ "|before={" ++ before ++ "}|afterFinish={" ++ after ++ "}",reports})
def project(value:State) -> State & View:
  match value:
    case State{token,returned,before,after,reports}:project_join(before,after,reports,Dump.u32_array(token),Observe.returned(returned))
