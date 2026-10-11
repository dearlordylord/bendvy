import Base
import ./foreign-consumer.bend as C
import ../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
def LocalWorld(~S:Data) -> Type:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>
def install(~S:Data,world:LocalWorld(~S)) -> C.CleanupApp(~S):LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~String),~C.observe1(~S),~C.folded(~S),~[C.parent_declaration(~S)],~C.clear(~S),~C.record(~S),~C.link_declaration(~S),LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~C.physical(~S),~C.folded(~S),~[],~C.clear(~S),~C.record(~S),~C.parent_declaration(~S),LC.empty(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~C.physical(~S),~C.folded(~S),~C.clear(~S),~C.record(~S),Build.Registered{world,Array.new(U32,0n,19),Tree.Recipe{},False{}})))
def built(~S:Data,state:LocalWorld(~S) & List<&2,W.Handle<S>>) -> C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>:
  match state:
    case (world,Con{_,Con{_,Con{_,Con{handle,Nil{}}}}}):(install(~S,world),Some{handle})
    case (world,_):(install(~S,world),None{})
def reserved_missing(~S:Data,owners:Array<U32>,recipe:Tree.Recipe<LocalWorld(~S),Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),C.observe2(~S)>,debug:Bool,seen:LocalWorld(~S) & W.Reservation<S>) -> C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>:
  match seen:
    case (world,W.Reserved{handle}):(LC.Installed{Build.Registered{world,owners,recipe,debug}},Some{handle})
    case (world,_):(LC.Installed{Build.Registered{world,owners,recipe,debug}},None{})
def reserve_missing(~S:Data,app:C.CleanupApp(~S)) -> C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>:
  match app:
    case LC.Installed{Build.Registered{world,owners,recipe,debug}}:reserved_missing(~S,owners,recipe,debug,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,world))
def done(~S:Data,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (_,text):head ++ "\nPEER_AFTER_MISSING\n" ++ text
def missing_after(~S:Data,peer:C.CleanupApp(~S),seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (_,text):done(~S,C.snapshot(~S,peer),head ++ "\nLOCAL_AFTER_MISSING\n" ++ text)
def missing_requested(~S:Data,peer:C.CleanupApp(~S),seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (local,text):missing_after(~S,peer,C.snapshot(~S,C.barrier(~S,local)),head ++ "\nMISSING=" ++ text)
def peer_foreign_after(~S:Data,local:C.CleanupApp(~S),missing:W.Handle<S>,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (peer,text):missing_requested(~S,peer,C.invoke(~S,local,missing,X.Success{}),head ++ "\nPEER_AFTER_FOREIGN\n" ++ text)
def foreign_after(~S:Data,peer:C.CleanupApp(~S),missing:W.Handle<S>,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (local,text):peer_foreign_after(~S,local,missing,C.snapshot(~S,peer),head ++ "\nLOCAL_AFTER_FOREIGN\n" ++ text)
def foreign_requested(~S:Data,peer:C.CleanupApp(~S),missing:W.Handle<S>,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (local,text):foreign_after(~S,peer,missing,C.snapshot(~S,C.barrier(~S,local)),head ++ "\nFOREIGN=" ++ text)
def peer_before(~S:Data,local:C.CleanupApp(~S),foreign:W.Handle<S>,missing:W.Handle<S>,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (peer,text):foreign_requested(~S,peer,missing,C.invoke(~S,local,foreign,X.Success{}),head ++ "\nPEER_BEFORE\n" ++ text)
def local_before(~S:Data,peer:C.CleanupApp(~S),foreign:W.Handle<S>,missing:W.Handle<S>,seen:C.CleanupApp(~S) & String,head:String) -> String:
  match seen:
    case (local,text):peer_before(~S,local,foreign,missing,C.snapshot(~S,peer),head ++ "\nLOCAL_BEFORE\n" ++ text)
def identities(~S:Data,next:W.Factory,foreign:W.Handle<S>,missing:W.Handle<S>) -> String:
  match next foreign missing:
    case W.Factory{n} W.Handle{fns,fid} W.Handle{mns,mid}:"factoryNext=" ++ U32.show(n) ++ "|foreign=" ++ U32.show(fns) ++ ":" ++ U32.show(fid) ++ "|missing=" ++ U32.show(mns) ++ ":" ++ U32.show(mid)
def missing_ready(~S:Data,peer:C.CleanupApp(~S),+foreign:W.Handle<S>,next:W.Factory,seen:C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match seen:
    case (local,Some{+missing}):local_before(~S,peer,foreign,missing,C.snapshot(~S,local),identities(~S,next,foreign,missing))
    case _:"MISSING_RESERVATION_FAILURE"
def peer_ready(~S:Data,local:C.CleanupApp(~S),next:W.Factory,seen:C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match seen:
    case (peer,Some{foreign}):missing_ready(~S,peer,foreign,next,reserve_missing(~S,local))
    case _:"PEER_RESERVATION_FAILURE"
def peer_created(~S:Data,local:C.CleanupApp(~S),creation:W.Creation<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> String:
  match creation:
    case W.Created{next,world}:peer_ready(~S,local,next,built(~S,C.spawn(~S,4n,(world,[]))))
    case _:"PEER_CREATE_FAILURE"
def local_ready(~S:Data,next:W.Factory,seen:C.CleanupApp(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match seen:
    case (local,Some{_}):peer_created(~S,local,W.create(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~C.empty(~S),next,O.Resources{Array.new(U32,0n,27),Array.new(U32,0n,28)}))
    case _:"LOCAL_RESERVATION_FAILURE"
def local_created(~S:Data,creation:W.Creation<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> String:
  match creation:
    case W.Created{next,world}:local_ready(~S,next,built(~S,C.spawn(~S,4n,(world,[]))))
    case _:"LOCAL_CREATE_FAILURE"
def run(~S:Data) -> String:local_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~C.empty(~S),W.factory(),O.Resources{Array.new(U32,0n,17),Array.new(U32,0n,18)}))
def main() -> IO(Unit):IO.print("ForeignAlpha\n" ++ run(~C.Alpha) ++ "\nForeignBeta\n" ++ run(~C.Beta))
