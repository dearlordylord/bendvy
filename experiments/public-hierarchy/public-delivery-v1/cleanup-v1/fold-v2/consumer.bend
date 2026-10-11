import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import ../../owners.bend as O
import ../../observer.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/relation-cleanup.bend as Cleanup

type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Parent","Children",G.Hierarchy{}}
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Link","Incoming",G.Ordinary{}}
def empty(~S:Data,_:Unit) -> A.Store<S,O.Components<S>>:
  A.empty(~S,~O.Components<S>,O.Components{Col.Column{Col.absent(~O.Payload,3n),[]}})
def populated(~S:Data,outcome:Col.SwapOutcome<S,O.Payload>,graph:G.Graph<S>) -> A.Store<S,O.Components<S>> & Unit:
  match outcome:
    case Col.Accepted{column,_}: (A.Store{O.Components{column},graph},Unit{})
    case Col.Rejected{column,_}: (A.Store{O.Components{column},graph},Unit{})
def populate(~S:Data,store:A.Store<S,O.Components<S>>,handle:W.Handle<S>) -> A.Store<S,O.Components<S>> & Unit:
  match store handle:
    case A.Store{O.Components{column},graph} W.Handle{_,+id}: populated(~S,Col.swap(~S,~O.Payload,column,id,Some{O.Payload{ANode{ALeaf{id},ALeaf{U32.mul(id,10)}},id}}),graph)
def activated(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & W.Status,handle:W.Handle<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  (world,_) = result
  (world,handle <> handles)
def prepared(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & Unit,+handle:W.Handle<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  (world,_) = result
  activated(~S,W.activate(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world,handle),handle,handles)
def reserved(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & W.Reservation<S>,handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  match result:
    case (world,W.Reserved{+handle}): prepared(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Unit,store => populate(~S,store,handle),world),handle,handles)
    case (world,_): (world,handles)
def spawn(~S:Data,n:Nat,state:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>:
  match n state:
    case 0n state: state
    case 1n+rest Tuple{world,handles}: spawn(~S,rest,reserved(~S,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world),handles))
def write_body(~S:Data,-F:Type,caps:P.Writable<F,S>,targets:P.Targets<S>,owner:F) -> F & A.QueueStatus:
  P.relate_live(F,S,caps,owner,targets)
def queue(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,A.Notice<S,U32>>,source:W.Handle<S>,target:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,A.Notice<S,U32>>:
  O.queue_done(~S,P.invoke_write(~S,~O.Components<S>,~Array<U32>,~U32,~descriptor,~A.QueueStatus,~write_body(~S),P.Targets{source,target},tx))
def read_body(~S:Data,-F:Type,caps:H.Read<F,S>,target:W.Handle<S>,owner:F) -> F & Maybe<&2,H.Frame<S>>:
  H.read(F,S,caps,owner,target)
def show_handles(~S:Data,xs:List<&2,W.Handle<S>>) -> String:
  match xs:
    case []: ""
    case W.Handle{ns,id} <> rest: U32.show(ns) ++ ":" ++ U32.show(id) ++ "," ++ show_handles(~S,rest)
def show_path(~S:Data,path:H.Path<S>) -> String:
  match path:
    case H.Complete{handles}: show_handles(~S,handles)
    case H.Incomplete{handles,pending}: "INCOMPLETE:" ++ show_handles(~S,handles) ++ ":" ++ show_handles(~S,pending)
def show_handle(~S:Data,value:Maybe<&2,W.Handle<S>>) -> String:
  match value:
    case None{}: "absent"
    case Some{W.Handle{ns,id}}: U32.show(ns) ++ ":" ++ U32.show(id)
def show_frame(~S:Data,value:Maybe<&2,H.Frame<S>>) -> String:
  match value:
    case None{}: "MissingEntity"
    case Some{H.Frame{entity,p,children,ancestors,root,depth,breadth}}: "entity=" ++ show_handle(~S,Some{entity}) ++ "|parent=" ++ show_handle(~S,p) ++ "|children=" ++ show_handles(~S,children) ++ "|ancestors=" ++ show_path(~S,ancestors) ++ "|root=" ++ show_handle(~S,root) ++ "|depth=" ++ show_path(~S,depth) ++ "|breadth=" ++ show_path(~S,breadth)
def projected_component(~S:Data,result:Col.Column<S,O.Payload> & Maybe<&2,List<&2,U32>>) -> O.Components<S> & Maybe<&2,List<&2,U32>>:
  (column,view) = result
  (O.Components{column},view)
def read_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & Maybe<&2,H.Frame<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,frame) = result
  (world,show_frame(~S,frame))
def read(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,target:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  read_done(~S,H.grant(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Maybe<&2,H.Frame<S>>,~read_body(~S),target,world))
def tail(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,head:String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,value) = result
  (world,head ++ "\n" ++ value)
def each_fold(~S:Data,handles:List<&2,W.Handle<S>>,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  match handles result:
    case Nil{} Tuple{world,text}: tail(~S,Obs.observe(~S,world),text)
    case Con{head,rest} Tuple{world,text}: each_fold(~S,rest,tail(~S,read(~S,world,head),text))
def each(~S:Data,handles:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  match handles:
    case []: Obs.observe(~S,world)
    case head <> rest: each_fold(~S,rest,read(~S,world,head))
def cleared_owner(~S:Data,projected:O.Payload & List<&2,U32>,column:Col.Column<S,O.Payload>,id:U32) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  (_,_) = projected
  (O.Components{column},[A.ComponentRemoved{id}])
def cleared(~S:Data,outcome:Col.SwapOutcome<S,O.Payload>,id:U32) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  match outcome:
    case Col.Accepted{column,None{}}: (O.Components{column},[])
    case Col.Accepted{column,Some{owner}}: cleared_owner(~S,O.project_payload(owner),column,id)
    case Col.Rejected{column,_}: (O.Components{column},[])
def clear(~S:Data,components:O.Components<S>,handle:W.Handle<S>) -> O.Components<S> & List<&2,A.Notice<S,U32>>:
  match components handle:
    case O.Components{column} W.Handle{_,+id}: cleared(~S,Col.clear(~S,~O.Payload,column,id),id)
def despawn_notice(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}: A.Original{U32.add(1000,id)}
def cleanup_result(~S:Data,result:Cleanup.CleanupResult<S,O.Components<S>,Array<U32>,U32>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>:
  match result:
    case Cleanup.Complete{world}: world
    case Cleanup.Incomplete{world,frames}: W.event_publish(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world,[A.CleanupPaused{frames}])
def apply_cleanup(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,handle:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>:
  cleanup_result(~S,Cleanup.automatic(~S,~O.Components<S>,~Array<U32>,~U32,~clear(~S),~despawn_notice(~S),world,handle,[parent(~S),link(~S)]))
def queue_cleanup(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,handle:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>:
  O.commit(~S,X.stage(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,X.begin(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,world),world => apply_cleanup(~S,world,handle)),X.Success{})
def final(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (_,text) = observed
  text
type Operation<S:Data> is Data:
  Operation{label:String,target:W.Handle<S>}
def record_applied(~S:Data,label:String,prefix:String,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,text) = observed
  (world,prefix ++ "\n" ++ label ++ "_APPLIED\n" ++ text)
def record_pending(~S:Data,+label:String,handles:List<&2,W.Handle<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,prefix:String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,text) = observed
  record_applied(~S,label,prefix ++ "\n" ++ label ++ "_PENDING\n" ++ text,each(~S,handles,W.barrier(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world)))
def process(~S:Data,operation:Operation<S>,state:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,+handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  match operation state:
    case Operation{label,target} Tuple{world,prefix}: record_pending(~S,label,handles,each(~S,handles,queue_cleanup(~S,world,target)),prefix)
def fold(~S:Data,operations:List<&2,Operation<S>>,state:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,+handles:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  match operations:
    case Nil{}: state
    case Con{operation,rest}: fold(~S,rest,process(~S,operation,state,handles),handles)
def initial(~S:Data,+handles:List<&2,W.Handle<S>>,h1:W.Handle<S>,+h2:W.Handle<S>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  final(~S,fold(~S,[Operation{"INTERMEDIATE",h2},Operation{"REPEAT",h2},Operation{"ROOT",h1}],(world,"INITIAL\n" ++ text),handles))
def seeded(~S:Data,state:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,Con{+h4,Con{+h3,Con{+h2,Con{+h1,Nil{}}}}}): initial(~S,[h1,h2,h3,h4],h1,h2,each(~S,[h1,h2,h3,h4],W.barrier(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,O.commit(~S,queue(~S,~link(~S),queue(~S,~parent(~S),queue(~S,~parent(~S),queue(~S,~parent(~S),X.begin(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,world),h2,h1),h3,h1),h4,h2),h3,h2),X.Success{}))))
    case _: "RESERVATION_FAILURE"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: seeded(~S,spawn(~S,4n,(world,[])))
    case _: "CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),W.factory(),Array.new(U32,0n,17)))
def main() -> IO(Unit):
  IO.print("HierarchyAlpha\n" ++ run(~Alpha) ++ "\nHierarchyBeta\n" ++ run(~Beta))
