import Base
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/consumer.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/fixture.bend as Seed
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-reorder.bend as Reorder
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

type Alpha is Data: Alpha{}
type Beta is Data: Beta{}
type Action<S:Data> is Data:
  Relate{label:String,source:W.Handle<S>,target:W.Handle<S>}
  Reorder{label:String,parent:W.Handle<S>,children:List<&2,W.Handle<S>>}
def label(~S:Data,value:Action<S>) -> String:
  match value:
    case Relate{text,_,_}:text
    case Reorder{text,_,_}:text
def status(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure"
def queue(~S:Data,value:Action<S>,app:C.Application(~S)) -> C.Application(~S) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>:
  match value:
    case Relate{_,source,target}:App.relate_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),~Unit,app,P.Targets{source,target},Tx.Success{})
    case Reorder{_,parent,children}:App.reorder_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),~Unit,app,Reorder.Args{parent,children},Tx.Success{})
def barrier(~S:Data,app:C.Application(~S)) -> C.Application(~S):
  App.barrier_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),app)
def applied_done(~S:Data,head:String,result:C.Application(~S) & String,next:C.Application(~S) -> String -> C.Application(~S) & String) -> C.Application(~S) & String:
  match result:
    case (app,text):next(app,head ++ "\n" ++ text)
def queued_seen(~S:Data,text:String,head:String,result:C.Application(~S) & String,next:C.Application(~S) -> String -> C.Application(~S) & String) -> C.Application(~S) & String:
  match result:
    case (app,observed):applied_done(~S,head ++ "\n" ++ observed,C.snapshot(~S,text ++ ".APPLIED",barrier(~S,app)),next)
def queued_done(~S:Data,+text:String,head:String,result:C.Application(~S) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>,next:C.Application(~S) -> String -> C.Application(~S) & String) -> C.Application(~S) & String:
  match result:
    case (app,DTO.Product{queued,finished}):queued_seen(~S,text,head ++ "\n" ++ text ++ ".QUEUE:" ++ status(queued) ++ ":" ++ outcome(finished),C.snapshot(~S,text ++ ".QUEUED",app),next)
def before_done(~S:Data,+value:Action<S>,result:C.Application(~S) & String,next:C.Application(~S) -> String -> C.Application(~S) & String) -> C.Application(~S) & String:
  match result:
    case (app,text):queued_done(~S,label(~S,value),text,queue(~S,value,app),next)
def steps(~S:Data,values:List<&2,Action<S>>,app:C.Application(~S),history:String) -> C.Application(~S) & String:
  match values:
    case []:C.joined(~S,history,C.snapshot(~S,"FINAL",app))
    case +value <> rest:before_done(~S,value,C.snapshot(~S,label(~S,value) ++ ".BEFORE",app),app => text => steps(~S,rest,app,history ++ "\n" ++ text))
def finished(~S:Data,result:C.Application(~S) & String) -> String:
  match result:
    case (_,text):text
def initial_applied(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,+missing:W.Handle<S>,result:C.Application(~S) & String) -> String:
  match result:
    case (app,text):finished(~S,steps(~S,[Relate{"self",h1,h1},Relate{"cycle",h1,h4},Reorder{"missing-child",h1,[missing,h3,h2]},Reorder{"duplicate-child",h1,[h3,h3,h2]},Reorder{"unrelated-child",h1,[h4,h3,h2]},Reorder{"child-set",h1,[h3]}],app,text))
def initial_pending(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,+missing:W.Handle<S>,result:C.Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ initial_applied(~S,h1,h2,h3,h4,missing,C.snapshot(~S,"INITIAL_APPLIED",barrier(~S,app)))
def initial(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,+missing:W.Handle<S>,result:C.Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ initial_pending(~S,h1,h2,h3,h4,missing,C.snapshot(~S,"INITIAL_PENDING",C.relate(~S,C.relate(~S,C.relate(~S,app,h2,h1),h3,h1),h4,h2)))
def reserved(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,result:C.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{missing}):initial(~S,h1,h2,h3,h4,missing,C.snapshot(~S,"INITIAL_BEFORE",App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}})))
    case _:"RESERVATION_FAILURE"
def spawned(~S:Data,result:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match result:
    case (world,Con{h4,Con{h3,Con{h2,Con{h1,Nil{}}}}}):reserved(~S,h1,h2,h3,h4,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world))
    case _:"SPAWN_FAILURE"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:spawned(~S,Seed.spawn(~S,4n,(world,[])))
    case _:"CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("RejectionsAlpha\n" ++ run(~Alpha) ++ "\nRejectionsBeta\n" ++ run(~Beta))
