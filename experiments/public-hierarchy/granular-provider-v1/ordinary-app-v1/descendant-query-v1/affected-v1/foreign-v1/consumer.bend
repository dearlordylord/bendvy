import Base
import ../../consumer.bend as C
import ./view.bend as View
import ../../fixture.bend as Seed
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ../../owners.bend as O
def finished(~S:Data,text:String,local:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (_,peerText):text ++ "\n" ++ peerText
def local_after(~S:Data,text:String,peer:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (local,localText):finished(~S,text ++ "\n" ++ localText,local,View.snapshot(~S,"PEER_AFTER",peer))
def dead_done(~S:Data,text:String,peer:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (local,row):local_after(~S,text ++ "\nDEAD_READ:" ++ row,peer,View.snapshot(~S,"LOCAL_AFTER",local))
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def deactivated(~S:Data,+localRoot:W.Handle<S>,text:String,peer:View.Application(~S),owners:Array<U32>,recipe:Relation.Recipe(~S,~O.Components<S>,~Array<U32>,~U32,~App.declaration(~S,C.hierarchy(~S)),~Array<U32>,~String,~View.prior(~S),~C.fold(~S)),debug:Bool,result:C.World(~S) & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):dead_done(~S,text ++ "\nDEACTIVATE:Accepted",peer,View.read(~S,Build.Registered{world,owners,recipe,debug},localRoot))
    case (world,W.Rejected{error}):dead_done(~S,text ++ "\nDEACTIVATE:Rejected:" ++ world_error(error),peer,View.read(~S,Build.Registered{world,owners,recipe,debug},localRoot))
def deactivate(~S:Data,+localRoot:W.Handle<S>,text:String,local:View.Application(~S),peer:View.Application(~S)) -> String:
  match local:
    case Build.Registered{world,owners,recipe,debug}:deactivated(~S,localRoot,text,peer,owners,recipe,debug,W.deactivate(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world,localRoot))
def missing_done(~S:Data,+localRoot:W.Handle<S>,text:String,peer:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (local,row):deactivate(~S,localRoot,text ++ "\nMISSING_READ:" ++ row,local,peer)
def foreign_done(~S:Data,+localRoot:W.Handle<S>,+missing:W.Handle<S>,text:String,peer:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (local,row):missing_done(~S,localRoot,text ++ "\nFOREIGN_READ:" ++ row,peer,View.read(~S,local,missing))
def peer_seen(~S:Data,+peerRoot:W.Handle<S>,+localRoot:W.Handle<S>,+missing:W.Handle<S>,text:String,local:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (peer,peerText):foreign_done(~S,localRoot,missing,text ++ "\n" ++ peerText,peer,View.read(~S,local,peerRoot))
def local_seen(~S:Data,+peerRoot:W.Handle<S>,+localRoot:W.Handle<S>,+missing:W.Handle<S>,peer:View.Application(~S),result:View.Application(~S) & String) -> String:
  match result:
    case (local,text):peer_seen(~S,peerRoot,localRoot,missing,text,local,View.snapshot(~S,"PEER_BEFORE",peer))
def peer_seeded(~S:Data,+localRoot:W.Handle<S>,+missing:W.Handle<S>,local:View.Application(~S),result:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match result:
    case (world,_ <> _ <> _ <> peerRoot <> []):local_seen(~S,peerRoot,localRoot,missing,App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{1901},ALeaf{1902}},Tree.Recipe{},False{}}),View.snapshot(~S,"LOCAL_BEFORE",local))
    case _:"PEER_SPAWN_HANDLE_MISSING"
def peer_created(~S:Data,+localRoot:W.Handle<S>,+missing:W.Handle<S>,local:View.Application(~S),result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:peer_seeded(~S,localRoot,missing,local,Seed.spawn(~S,4n,(world,[])))
    case _:"PEER_CREATE_REFUSAL"
def local_reserved(~S:Data,+localRoot:W.Handle<S>,factory:W.Factory,result:C.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{missing}):peer_created(~S,localRoot,missing,App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~View.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}}),W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),factory,ANode{ALeaf{27},ALeaf{28}}))
    case (_,W.ReservationRejected{error}):"MISSING_RESERVATION_REFUSED:" ++ world_error(error)
def local_seeded(~S:Data,factory:W.Factory,result:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match result:
    case (world,_ <> _ <> _ <> localRoot <> []):local_reserved(~S,localRoot,factory,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world))
    case _:"LOCAL_SPAWN_HANDLE_MISSING"
def local_created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{factory,world}:local_seeded(~S,factory,Seed.spawn(~S,4n,(world,[])))
    case _:"LOCAL_CREATE_REFUSAL"
def run(~S:Data) -> String:
  local_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("DescendantForeignAlpha\n" ++ run(~C.Alpha) ++ "\nDescendantForeignBeta\n" ++ run(~C.Beta))
