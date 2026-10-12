import Base
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/granular-provider-v1/ordinary-app-v1/affected-v1/foreign-observation.bend as View
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
type Apps<S:Data> is Type:
  Apps{local:View.Application(~S),peer:View.Application(~S)}
type Action<S:Data> is Data:
  Action{label:String,parent:W.Handle<S>,children:List<&2,W.Handle<S>>}
def status(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure"
def barrier(~S:Data,app:View.Application(~S)) -> View.Application(~S):
  App.barrier_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),app)
def peer_snapshot(~S:Data,local:View.Application(~S),head:String,result:View.Application(~S) & String) -> Apps<S> & String:
  match result:
    case (peer,text):(Apps{local,peer},head ++ "\n" ++ text)
def local_snapshot(~S:Data,+label:String,peer:View.Application(~S),result:View.Application(~S) & String) -> Apps<S> & String:
  match result:
    case (local,text):peer_snapshot(~S,local,text,View.snapshot(~S,label ++ ".PEER",peer))
def snapshot(~S:Data,+label:String,apps:Apps<S>) -> Apps<S> & String:
  match apps:
    case Apps{local,peer}:local_snapshot(~S,label,peer,View.snapshot(~S,label ++ ".LOCAL",local))
def applied(~S:Data,history:String,result:Apps<S> & String,next:Apps<S> -> String -> String) -> String:
  match result:
    case (apps,text):next(apps,history ++ "\n" ++ text)
def queued_snapshot(~S:Data,+label:String,history:String,result:Apps<S> & String,next:Apps<S> -> String -> String) -> String:
  match result:
    case (Apps{local,peer},text):applied(~S,history ++ "\n" ++ text,snapshot(~S,label ++ ".APPLIED",Apps{barrier(~S,local),peer}),next)
def queued(~S:Data,+label:String,history:String,peer:View.Application(~S),result:View.Application(~S) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>,next:Apps<S> -> String -> String) -> String:
  match result:
    case (local,DTO.Product{queued,finished}):queued_snapshot(~S,label,history ++ "\n" ++ label ++ ".QUEUE:" ++ status(queued) ++ ":" ++ outcome(finished),snapshot(~S,label ++ ".QUEUED",Apps{local,peer}),next)
def before(~S:Data,value:Action<S>,result:Apps<S> & String,next:Apps<S> -> String -> String) -> String:
  match value result:
    case Action{label,parent,children},(Apps{local,peer},text):queued(~S,label,text,peer,App.reorder_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),~Unit,local,Reorder.Args{parent,children},Tx.Success{}),next)
def label(~S:Data,value:Action<S>) -> String:
  match value:
    case Action{text,_,_}:text
def steps(~S:Data,values:List<&2,Action<S>>,apps:Apps<S>,history:String) -> String:
  match values:
    case []:history
    case +value <> rest:before(~S,value,snapshot(~S,label(~S,value) ++ ".BEFORE",apps),apps => text => steps(~S,rest,apps,history ++ "\n" ++ text))
def peer_spawned(~S:Data,local:View.Application(~S),+localh1:W.Handle<S>,result:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match result:
    case (world,Con{_,Con{_,Con{_,Con{+peerh1,Nil{}}}}}):steps(~S,[Action{"foreign-parent",peerh1,[localh1]},Action{"foreign-child",localh1,[peerh1]}],Apps{local,App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{1901},ALeaf{1902}},Tree.Recipe{},False{}})},"FOREIGN")
    case _:"PEER_SPAWN_FAILURE"
def peer_created(~S:Data,local:View.Application(~S),localh1:W.Handle<S>,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:peer_spawned(~S,local,localh1,Seed.spawn(~S,4n,(world,[])))
    case _:"PEER_CREATE_FAILURE"
def local_spawned(~S:Data,factory:W.Factory,result:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match result:
    case (world,Con{_,Con{_,Con{_,Con{h1,Nil{}}}}}):peer_created(~S,App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}}),h1,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),factory,ANode{ALeaf{27},ALeaf{28}}))
    case _:"LOCAL_SPAWN_FAILURE"
def local_created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{factory,world}:local_spawned(~S,factory,Seed.spawn(~S,4n,(world,[])))
    case _:"LOCAL_CREATE_FAILURE"
def run(~S:Data) -> String:
  local_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("ReorderForeignAlpha\n" ++ run(~Alpha) ++ "\nReorderForeignBeta\n" ++ run(~Beta))
