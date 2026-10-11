import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O

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
def show_optional_path(~S:Data,value:Maybe<&2,H.Path<S>>) -> String:
  match value:
    case None{}: "MissingEntity"
    case Some{value}: show_path(~S,value)
