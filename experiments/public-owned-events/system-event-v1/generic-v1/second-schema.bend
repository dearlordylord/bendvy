import Base
import system.bend as S
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/registered-v1/observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Q
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

type Schema is Data: Schema{}
def runner(world:W.World<Schema,Array<U32>,Array<Bool>,Bool>,input:Ev.Input<Bool,Array<U32>>) -> Sys.Outcome<W.World<Schema,Array<U32>,Array<Bool>,Bool>,String,Array<U32>>:
  match input:
    case Ev.Input{_,_,args}: Sys.Succeeded{world,args}
def Registry() -> Type: S.Registration<Schema,Array<U32>,Array<Bool>,Bool,Array<U32>,String,Array<U32>,runner>
type OwnerMeta is Data: OwnerMeta{slot:String,clauses:List<&2,Q.Clause<Schema>>,readerNamespace:U32,readerId:U32,expectedRegistry:U32,registryNamespace:U32,registryId:U32,name:String,access:List<&2,String>,cursor:U32}
type WorldView is Data: WorldView{namespace:U32,nextId:U32,highWater:U32,live:List<&2,Bool>,capacity:U32,depth:Nat,store:List<&2,U32>,resources:List<&2,Bool>,events:List<&2,Bool>,pending:Nat,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type EventView is Data: EventView{namespace:U32,batches:List<&2,Ev.Batch<Bool>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat,values:List<&2,Bool>}
type Observed is Data:
  Success{world:WorldView,events:EventView,owner:OwnerMeta,outputs:List<&2,List<&2,U32>>}
  Refused{world:WorldView,events:EventView,owner:OwnerMeta,args:List<&2,U32>}
  BodyFailed{world:WorldView,events:EventView,owner:OwnerMeta,error:String,outputs:List<&2,List<&2,U32>>}
  SetupRefused{world:WorldView,events:EventView}
def bools(owner:Array<Bool>) -> List<&2,Bool>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,bools(left),bools(right))
def observed_cells(result:Array<U32> & List<&2,U32>) -> List<&2,U32>:
  match result:
    case (_,values): values
def cells(owner:Array<U32>) -> List<&2,U32>: observed_cells(O.array(owner))
def outputs(values:List<Array<U32>>) -> List<&2,List<&2,U32>>:
  match values:
    case []: []
    case head <> tail: cells(head) <> outputs(tail)
def world(owner:W.World<Schema,Array<U32>,Array<Bool>,Bool>) -> WorldView:
  match owner:
    case W.World{namespace,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}: WorldView{namespace,next,high,bools(live),capacity,depth,cells(store),bools(resources),events,List.length(&1,W.World<Schema,Array<U32>,Array<Bool>,Bool> -> W.World<Schema,Array<U32>,Array<Bool>,Bool>,pending),registrations,nextSystem,clock}
def event(owner:Domains.Events<Schema,Bool>) -> EventView:
  match owner:
    case Domains.Events{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,values}: EventView{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,values}
def metadata(owner:Ordinary.Owner<Schema,Registry()>) -> OwnerMeta:
  match owner:
    case Ordinary.Owner{S.Registration{Ev.Reader{namespace,id,expected},Sys.Registry{actual,registryId,name,access,cursor}},slot,clauses}: OwnerMeta{slot,clauses,namespace,id,expected,actual,registryId,name,access,cursor}
def returned(result:S.Returned<Schema,Array<U32>,Array<Bool>,Bool,Array<U32>,String,Array<U32>,runner>) -> Observed:
  match result:
    case S.Returned{events,S.Reached{owner,Sys.Succeeded{w,_},values}}: Success{world(w),event(events),metadata(owner),outputs(values)}
    case S.Returned{events,S.Reached{owner,Sys.Failed{w,error},values}}: BodyFailed{world(w),event(events),metadata(owner),error,outputs(values)}
    case S.Returned{events,S.RegistrationRefused{owner,w,args}}: Refused{world(w),event(events),metadata(owner),cells(args)}
def foreign(owner:Ordinary.Owner<Schema,Registry()>,wrong:Bool) -> Ordinary.Owner<Schema,Registry()>:
  match owner wrong:
    case Ordinary.Owner{S.Registration{Ev.Reader{_,id,expected},registry},slot,clauses}, True{}: Ordinary.Owner{S.Registration{Ev.Reader{999,id,expected},registry},slot,clauses}
    case owner, False{}: owner
def detached(wrong:Bool,owner:Ordinary.Owner<Schema,Registry()>,result:Domains.Detached<Schema,Array<U32>,Array<Bool>,Bool>) -> Observed:
  match result:
    case Domains.Detached{w,events}: returned(S.run(~Schema,~Array<U32>,~Array<Bool>,~Bool,~Array<U32>,~String,~Array<U32>,~runner,events,foreign(owner,wrong),w,ANode{ALeaf{71},ALeaf{72}}))
def setup_refused(result:Domains.Detached<Schema,Array<U32>,Array<Bool>,Bool>) -> Observed:
  match result:
    case Domains.Detached{w,events}: SetupRefused{world(w),event(events)}
def defined(wrong:Bool,result:S.Defined<Schema,Array<U32>,Array<Bool>,Bool,Array<U32>,String,Array<U32>,runner>) -> Observed:
  match result:
    case S.DefineRefused{runtime}: setup_refused(Domains.detach(~Schema,~Array<U32>,~Array<Bool>,~Bool,runtime,[]))
    case S.Defined{runtime,owner}: detached(wrong,owner,Domains.detach(~Schema,~Array<U32>,~Array<Bool>,~Bool,runtime,[]))
def run(wrong:Bool) -> Observed:
  defined(wrong,S.define(~Schema,~Array<U32>,~Array<Bool>,~Bool,~Array<U32>,~String,~Array<U32>,~runner,Ev.start(~Schema,~Array<U32>,~Array<Bool>,~Bool,W.World{2,1,0,ALeaf{False{}},1,0n,ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{True{}},ALeaf{False{}}},[],[],[],1,0},8n),"second","second-slot",[Q.Clause{"second-events",Q.Read{}}]))
type Report is Data: Report{success:Observed,refused:Observed}
def main() -> Report: Report{run(False{}),run(True{})}
