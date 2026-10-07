import Base
import relation-types.bend as G
import relation-graph.bend as Graph
import relation-commands.bend as A
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/commands.bend as Cmd

type Workshop is Data:
  Workshop{}
type Other is Data:
  Other{}
type Payload is Type:
  Payload{cells: Array<U32>,tag: U32}
type Components<S: Data> is Type:
  Components{column: Col.Column<S,Payload>}
def empty(~S: Data,_: Unit) -> A.Store<S,Components<S>>:
  A.empty(~S,~Components<S>,Components{Col.Column{ANode{ANode{ALeaf{Some{Payload{ALeaf{10},100}}},ALeaf{Some{Payload{ANode{ALeaf{20},ALeaf{21}},200}}}},ANode{ALeaf{Some{Payload{ANode{ANode{ALeaf{30},ALeaf{31}},ANode{ALeaf{32},ALeaf{33}}},300}}},ALeaf{Some{Payload{ANode{ANode{ANode{ALeaf{40},ALeaf{41}},ANode{ALeaf{42},ALeaf{43}}},ANode{ANode{ALeaf{44},ALeaf{45}},ANode{ALeaf{46},ALeaf{47}}}},400}}}}},[]}})
def activated(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & W.Status) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  (world,_) = result
  world
def reserved(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & W.Reservation<S>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world,handle))
    case (world,_): world
def spawn(~S: Data,n: Nat,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  match n:
    case 0n: world
    case 1n+rest: spawn(~S,rest,reserved(~S,W.reserve_id(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world)))
def cells_next(result: Array<U32> & List<&2,U32>,id: U32) -> Array<U32> & List<&2,U32>:
  (cells,ids) = result
  (cells,id <> ids)
def cells_done(result: Array<U32> & U32,next: Array<U32> -> Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (cells,id) = result
  cells_next(next(cells),id)
def project_cells(n: Nat,cells: Array<U32>,+index: U32) -> Array<U32> & List<&2,U32>:
  match n:
    case 0n: (cells,[])
    case 1n+rest: cells_done(Array.get(U32,cells,index),arr => project_cells(rest,arr,(index + 1 : U32)))
def project_payload_done(result: Array<U32> & List<&2,U32>,+tag: U32) -> Payload & List<&2,U32>:
  (cells,ids) = result
  (Payload{cells,tag},tag <> ids)
def project_payload_sized(result: Array<U32> & U32,tag: U32) -> Payload & List<&2,U32>:
  (cells,size) = result
  project_payload_done(project_cells(U32.to_nat(size),cells,0),tag)
def project_payload(owner: Payload) -> Payload & List<&2,U32>:
  match owner:
    case Payload{cells,tag}: project_payload_sized(Array.size(U32,cells),tag)
def show_ids(xs: List<&2,U32>) -> String:
  match xs:
    case []: ""
    case x <> rest: U32.show(x) ++ "," ++ show_ids(rest)
def show_maybe(value: Maybe<&2,List<&2,U32>>) -> String:
  match value:
    case None{}: "absent"
    case Some{xs}: show_ids(xs)
def observed_tail(~S: Data,result: Col.Column<S,Payload> & String,head: String) -> Col.Column<S,Payload> & String:
  (column,tail) = result
  (column,head ++ ";" ++ tail)
def observed_column(~S: Data,result: Col.Column<S,Payload> & Maybe<&2,List<&2,U32>>,next: Col.Column<S,Payload> -> Col.Column<S,Payload> & String) -> Col.Column<S,Payload> & String:
  (column,value) = result
  observed_tail(~S,next(column),show_maybe(value))
def observe_column(~S: Data,n: Nat,column: Col.Column<S,Payload>,+id: U32) -> Col.Column<S,Payload> & String:
  match n:
    case 0n: (column,"")
    case 1n+rest: observed_column(~S,Col.view(~S,~Payload,~List<&2,U32>,~project_payload,column,id),c => observe_column(~S,rest,c,(id + 1 : U32)))
def observe_store_done(~S: Data,result: Col.Column<S,Payload> & String,+graph: G.Graph<S>) -> A.Store<S,Components<S>> & String:
  (column,owners) = result
  (A.Store{Components{column},graph},owners ++ "|" ++ show_ids(Graph.inverse(~S,graph,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},1)) ++ ":" ++ show_ids(Graph.inverse(~S,graph,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},2)))
def observe_store(~S: Data,store: A.Store<S,Components<S>>) -> A.Store<S,Components<S>> & String:
  match store:
    case A.Store{Components{column},graph}: observe_store_done(~S,observe_column(~S,4n,column,1),graph)
def observe(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  W.with_store(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,~String,observe_store(~S),world)
def enqueue_loop(~S: Data,commands: List<(W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>)>,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  match commands:
    case []: world
    case command <> rest: enqueue_loop(~S,rest,W.enqueue(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world,command))
def enqueue(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,commands: List<(W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>)>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  enqueue_loop(~S,commands,world)
def finish(~S: Data,result: X.Returned<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,U32>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case X.Returned{world,_}: world
def publish(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,events: List<&2,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  W.event_publish(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world,events)
def commit(~S: Data,tx: X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,outcome: X.Outcome<U32>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>:
  finish(~S,Cmd.tx_finish(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,~U32,tx,outcome))
def queue_done(~S: Data,result: X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = result
  tx
def set(~S: Data,tx: X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,source: U32,target: U32) -> X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  queue_done(~S,A.queue_relate(~S,~Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{1,source},W.Handle{1,target}))
def output_pair(result: String & String) -> String:
  (a,b) = result
  a ++ "|" ++ b
def show_error(error: G.Error) -> String:
  match error:
    case G.MissingEntity{source}: "MissingEntity:" ++ U32.show(source)
    case G.MissingTargetEntity{source,target,name}: "MissingTargetEntity:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ name
    case G.SelfRelationNotAllowed{source,name}: "SelfRelationNotAllowed:" ++ U32.show(source) ++ ":" ++ name
    case G.HierarchyCycle{source,target,name}: "HierarchyCycle:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ name
    case _: "UNEXPECTED"
def show_notice(~S: Data,notice: A.Notice<S,U32>) -> String:
  match notice:
    case A.Original{event}: "Original:" ++ U32.show(event)
    case A.CleanupPaused{_}: "CLEANUP_INCOMPLETE"
    case A.ComponentRemoved{id}: "Removed:" ++ U32.show(id)
    case A.RelationFailed{G.Failure{G.Descriptor{key,name,inv,_},_,source,target,error}}: "Failure:" ++ U32.show(key) ++ ":" ++ name ++ ":" ++ inv ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ show_error(error)
def show_notices(~S: Data,notices: List<&2,A.Notice<S,U32>>) -> String:
  match notices:
    case []: ""
    case notice <> rest: show_notice(~S,notice) ++ ";" ++ show_notices(~S,rest)
def observe_notices(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & List<&2,A.Notice<S,U32>>,owners: String) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,notices) = result
  (world,owners ++ "|events=" ++ show_notices(~S,notices))
def observe_complete_join(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,owners) = result
  observe_notices(~S,W.events_view(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world),owners)
def metadata(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  match result:
    case (W.World{+ns,+next,+high,live,+cap,+depth,store,+resource,+events,pending,+registrations,+nextSys,+clock},value): (W.World{ns,next,high,live,cap,depth,store,resource,events,pending,registrations,nextSys,clock},value ++ "|meta=" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ U32.show(cap) ++ "," ++ U32.show(U32.from_nat(depth)) ++ "," ++ U32.show(resource) ++ "," ++ U32.show(nextSys) ++ "," ++ U32.show(clock))
def pending_observed(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & U32,value: String) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,count) = result
  (world,value ++ "|pending=" ++ U32.show(count))
def pending_join(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  pending_observed(~S,W.pending_count(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world),value)
def observe_complete(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String:
  pending_join(~S,metadata(~S,observe_complete_join(~S,observe(~S,world))))
def record(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String,next: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> -> String) -> String:
  (world,value) = result
  value ++ "\n" ++ next(world)
def final(~S: Data,result: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (_,value) = result
  value

def missing_after(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  final(~S,observe_complete(~S,W.barrier(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world)))
def missing_before(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  record(~S,observe_complete(~S,commit(~S,set(~S,X.begin(~W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),9,1),X.Success{})),missing_after(~S))
def failed_after(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  record(~S,observe_complete(~S,W.barrier(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world)),missing_before(~S))
def failed_system(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  record(~S,observe_complete(~S,commit(~S,set(~S,X.begin(~W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),1,2),X.Failure{99})),failed_after(~S))
def successful_barrier(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  record(~S,observe_complete(~S,W.barrier(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,world)),failed_system(~S))
def foreign_done(~S: Data,result: X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> String:
  match result:
    case (tx,A.MissingEntity{}): "foreign-target=MissingEntity\n" ++ record(~S,observe_complete(~S,commit(~S,tx,X.Success{})),successful_barrier(~S))
    case (tx,A.Queued{}): "foreign-target=Queued\n" ++ record(~S,observe_complete(~S,commit(~S,tx,X.Success{})),successful_barrier(~S))
def foreign_source_done(~S: Data,result: X.Tx<W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> String:
  match result:
    case (tx,A.MissingEntity{}): "foreign-source=MissingEntity\n" ++ foreign_done(~S,A.queue_relate(~S,~Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{1,3},W.Handle{2,2}))
    case (tx,A.Queued{}): "foreign-source=Queued\n" ++ foreign_done(~S,A.queue_relate(~S,~Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{1,3},W.Handle{2,2}))
def successful_queue(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  foreign_source_done(~S,A.queue_relate(~S,~Components<S>,~U32,~U32,set(~S,set(~S,X.begin(~W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),3,1),2,1),G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{2,3},W.Handle{1,2}))
def initial(~S: Data,world: W.World<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  record(~S,observe_complete(~S,spawn(~S,4n,world)),successful_queue(~S))
def created(~S: Data,result: W.Creation<S,A.Store<S,Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: initial(~S,world)
    case _: "CREATE_REJECTED"
def run(~S: Data) -> String:
  created(~S,W.create(~S,~A.Store<S,Components<S>>,~U32,~A.Notice<S,U32>,~empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print(run(~Workshop) ++ "\n" ++ run(~Other))
