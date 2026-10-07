import Base
import types.bend as G
import graph-core.bend as Graph
import world-adapter.bend as A
import owned-world.bend as O
import cleanup-core.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/transaction.bend as X
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/capabilities.bend as Cap

type Writable<H:Type,S:Data> is Type:
  Writable{despawn:Cap.Request<H,W.Handle<S>,A.QueueStatus>}
def cells_notices(~S:Data,cells:List<&2,U32>) -> List<&2,A.Notice<S,U32>>:
  match cells:
    case []: []
    case cell <> rest: A.Original{U32.add(100000,cell)} <> cells_notices(~S,rest)
def removed_projection(~S:Data,result:O.Payload & List<&2,U32>,column:Col.Column<S,O.Payload>,id:U32) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  (_,cells) = result
  (O.Components{column},A.ComponentRemoved{id} <> cells_notices(~S,cells))
def removed(~S:Data,outcome:Col.SwapOutcome<S,O.Payload>,id:U32) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  match outcome:
    case Col.Accepted{column,None{}}: (O.Components{column},[])
    case Col.Accepted{column,Some{owner}}: removed_projection(~S,O.project_payload(owner),column,id)
    case Col.Rejected{column,_}: (O.Components{column},[])
def clear(~S:Data,components:O.Components<S>,handle:W.Handle<S>) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  match components handle:
    case O.Components{column} W.Handle{_,+id}: removed(~S,Col.clear(~S,~O.Payload,column,id),id)
def despawn_notice(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}: A.Original{U32.add(1000,id)}
# Finite prototype uses an explicit budget and never labels exhaustion complete.
# It preserves complete owner+pending frames in a typed diagnostic notice.
def result_world(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,result:C.CleanupResult<S,O.Components<S>,U32,U32>,namespace:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case C.Complete{world}: world
    case C.Incomplete{world,frames}: W.event_publish(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,[A.CleanupPaused{frames}])

def apply(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,handle:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match handle:
    case W.Handle{+namespace,id}: result_world(~S,~descriptors,C.drive(~S,~O.Components<S>,~U32,~U32,~clear(~S),~despawn_notice(~S),128n,[G.CleanupEnter{id}],world,namespace,descriptors),namespace)
def queued(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,allowed:Bool,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus:
  match allowed:
    case False{}: (tx,A.MissingEntity{})
    case True{}: (X.stage(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,tx,world => apply(~S,~descriptors,world,handle)),A.Queued{})
def namespace_join(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & U32,undo:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,commands:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,events:List<&2,A.Notice<S,U32>>,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus:
  match observed handle:
    case (world,namespace) W.Handle{+ns,+id}: queued(~S,~descriptors,U32.is_eq(namespace,ns),X.Tx{world,undo,commands,events},W.Handle{ns,id})
def queue(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus:
  match tx:
    case X.Tx{world,undo,commands,events}: namespace_join(~S,~descriptors,W.namespace(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),undo,commands,events,handle)
def body(~S:Data,-H:Type,caps:Writable<H,S>,handle:W.Handle<S>,owner:H) -> H & A.QueueStatus:
  match caps:
    case Writable{Cap.Request{despawn}}: despawn(owner,handle)
def invoked(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus:
  body(~S,X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,Writable{Cap.Request{queue(~S,~descriptors)}},handle,tx)
def committed(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  (tx,_) = result
  Sys.Succeeded{O.commit(~S,tx,X.Success{}),Unit{}}
def runner(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,handle:W.Handle<S>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  committed(~S,invoked(~S,~descriptors,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),handle))
def show_edges(~S:Data,edges:List<&2,G.Edge<S>>) -> String:
  match edges:
    case []: ""
    case G.Edge{G.Descriptor{key,_,_,_},source,target} <> rest: U32.show(key) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ";" ++ show_edges(~S,rest)
def graph_edges(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{edges,_}: show_edges(~S,edges)
def edge_observer(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>> & String:
  match store:
    case A.Store{components,+graph}: (A.Store{components,graph},graph_edges(~S,graph))
def observed(~S:Data,value:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,edges:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = value
  (world,value ++ "|edges=" ++ edges)
def show_bool(value:Bool) -> String:
  match value:
    case True{}: "1,"
    case False{}: "0,"
def live_return(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,head:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,tail) = result
  (world,head ++ tail)
def live_next(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool,next:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  live_return(~S,next(world),show_bool(value))
def lives(~S:Data,n:Nat,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+id:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  match n:
    case 0n: (world,"")
    case 1n+rest: live_next(~S,W.valid(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,W.Handle{1,id}),world => lives(~S,rest,world,U32.add(id,1)))
def live_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,edges:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,values) = result
  observed(~S,O.observe_complete(~S,world),edges ++ "|live=" ++ values)
def edges_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,edges) = result
  live_done(~S,lives(~S,4n,world,1),edges)
def observe(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  edges_done(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~String,edge_observer(~S),world))
def setup(~S:Data,edges:List<&2,G.Edge<S>>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match edges:
    case []: world
    case G.Edge{d,source,target} <> rest: setup(~S,rest,A.apply_relate(~S,~O.Components<S>,~U32,~U32,world,d,W.Handle{1,source},W.Handle{1,target}))
def after(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (_,value) = result
  "after|" ++ value
def queued_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (world,value) = result
  "queued|" ++ value ++ "\n" ++ after(~S,observe(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world)))
def ran(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,runner(~S,~descriptors)>) -> String:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,_}}: queued_observed(~S,observe(~S,world))
    case _: "RUN_REJECTED"
def before(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,~destroy:U32,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,registry:Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,runner(~S,~descriptors)>) -> String:
  (world,value) = result
  "before|" ++ value ++ "\n" ++ ran(~S,~descriptors,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Unit,~runner(~S,~descriptors),registry,world,W.Handle{1,destroy}))
def registered(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,~destroy:U32,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Unit,runner(~S,~descriptors)>) -> String:
  match result:
    case Sys.Registered{world,registry}: before(~S,~descriptors,~destroy,observe(~S,world),registry)
    case _: "REGISTER_REJECTED"
def created(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,~edges:List<&2,G.Edge<S>>,~destroy:U32,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: registered(~S,~descriptors,~destroy,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Unit,~runner(~S,~descriptors),setup(~S,edges,O.spawn(~S,4n,world)),"relation-cleanup",["Relation.despawn"]))
    case _: "CREATE_REJECTED"
def run(~S:Data,~descriptors:List<&2,G.Descriptor<S>>,~edges:List<&2,G.Edge<S>>,~destroy:U32) -> String:
  created(~S,~descriptors,~edges,~destroy,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),W.factory(),77))
def cases(~S:Data) -> String:
  "ordinary\n" ++ run(~S,~[G.Descriptor{1,"R1","Sources1",G.Ordinary{}}],~[G.Edge{G.Descriptor{1,"R1","Sources1",G.Ordinary{}},3,1},G.Edge{G.Descriptor{1,"R1","Sources1",G.Ordinary{}},2,1}],~1) ++ "\nordinary-source\n" ++ run(~S,~[G.Descriptor{1,"R1","Sources1",G.Ordinary{}}],~[G.Edge{G.Descriptor{1,"R1","Sources1",G.Ordinary{}},3,1},G.Edge{G.Descriptor{1,"R1","Sources1",G.Ordinary{}},2,1}],~3) ++ "\nhierarchy\n" ++ run(~S,~[G.Descriptor{1,"R1","Sources1",G.Hierarchy{}}],~[G.Edge{G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},3,1},G.Edge{G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},2,1},G.Edge{G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},4,2}],~1) ++ "\ncycle-one\n" ++ run(~S,~[G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},G.Descriptor{2,"R2","Sources2",G.Hierarchy{}}],~[G.Edge{G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},1,2},G.Edge{G.Descriptor{2,"R2","Sources2",G.Hierarchy{}},2,1}],~1) ++ "\ncycle-two\n" ++ run(~S,~[G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},G.Descriptor{2,"R2","Sources2",G.Hierarchy{}}],~[G.Edge{G.Descriptor{1,"R1","Sources1",G.Hierarchy{}},1,2},G.Edge{G.Descriptor{2,"R2","Sources2",G.Hierarchy{}},2,1}],~2)
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ cases(~O.Workshop) ++ "\nOther\n" ++ cases(~O.Other))
