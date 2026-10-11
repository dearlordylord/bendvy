import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import ../owners.bend as O
import ../observer.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/relation-reorder.bend as Reorder

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
def reorder_body(~S:Data,-F:Type,caps:Reorder.Writable<F,S>,args:Reorder.Args<S>,owner:F) -> F & A.QueueStatus:
  Reorder.body(~S,F,caps,args,owner)
def reorder(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,A.Notice<S,U32>>,args:Reorder.Args<S>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>:
  O.commit(~S,O.queue_done(~S,Reorder.invoke(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~A.QueueStatus,~reorder_body(~S),args,tx)),X.Success{})
def final(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (_,text) = observed
  text
def reordered(~S:Data,+handles:List<&2,W.Handle<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  "REORDER_PENDING\n" ++ text ++ "\nREORDER_APPLIED\n" ++ final(~S,each(~S,handles,W.barrier(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world)))
def reparent_applied_ready(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  "REPARENT_APPLIED\n" ++ text ++ "\n" ++ reordered(~S,[h1,h2,h3,h4],each(~S,[h1,h2,h3,h4],reorder(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,world),Reorder.Args{h1,[h3,h2]})))
def reparent_applied(~S:Data,+handles:List<&2,W.Handle<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  match handles:
    case Con{h1,Con{h2,Con{h3,Con{h4,Nil{}}}}}: reparent_applied_ready(~S,h1,h2,h3,h4,observed)
    case _: "HANDLE_LAYOUT_FAILURE"
def reparent_pending(~S:Data,+handles:List<&2,W.Handle<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  "REPARENT_PENDING\n" ++ text ++ "\n" ++ reparent_applied(~S,handles,each(~S,handles,W.barrier(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world)))
def initial_ready(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  "INITIAL\n" ++ text ++ "\n" ++ reparent_pending(~S,[h1,h2,h3,h4],each(~S,[h1,h2,h3,h4],O.commit(~S,queue(~S,~parent(~S),X.begin(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,world),h4,h3),X.Success{})))
def initial(~S:Data,+handles:List<&2,W.Handle<S>>,observed:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> String:
  match handles:
    case Con{h1,Con{h2,Con{h3,Con{h4,Nil{}}}}}: initial_ready(~S,h1,h2,h3,h4,observed)
    case _: "HANDLE_LAYOUT_FAILURE"
def seeded(~S:Data,state:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,Con{+h4,Con{+h3,Con{+h2,Con{+h1,Nil{}}}}}): initial(~S,[h1,h2,h3,h4],each(~S,[h1,h2,h3,h4],W.barrier(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,O.commit(~S,queue(~S,~parent(~S),queue(~S,~parent(~S),queue(~S,~parent(~S),X.begin(~W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~A.Notice<S,U32>,world),h2,h1),h3,h1),h4,h2),X.Success{}))))
    case _: "RESERVATION_FAILURE"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: seeded(~S,spawn(~S,4n,(world,[])))
    case _: "CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~empty(~S),W.factory(),Array.new(U32,0n,17)))
def main() -> IO(Unit):
  IO.print("HierarchyAlpha\n" ++ run(~Alpha) ++ "\nHierarchyBeta\n" ++ run(~Beta))
