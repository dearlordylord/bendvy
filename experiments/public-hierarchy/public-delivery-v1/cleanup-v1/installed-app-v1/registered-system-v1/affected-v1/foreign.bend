import Base
import ./foreign-consumer.bend as C
import ../../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup-system.bend as System
def LocalWorld(~S:Data) -> Type:W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>
def install(~S:Data,world:LocalWorld(~S)) -> System.Defined<C.CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S))>:
  System.register_app(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S),~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~C.observe2(~S),~C.folded(~S),~C.clear_declaration(~S),LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~String),~C.observe1(~S),~C.folded(~S),~[C.parent_declaration(~S)],~C.clear(~S),~C.record(~S),~C.link_declaration(~S),LC.install_relation(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~C.physical(~S),~C.folded(~S),~[],~C.clear(~S),~C.record(~S),~C.parent_declaration(~S),LC.empty(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~C.physical(~S),~C.folded(~S),~C.clear(~S),~C.record(~S),Build.Registered{world,Array.new(U32,0n,19),Tree.Recipe{},False{}}))),"LinkedCleanup")
def reserved_missing(~S:Data,owner:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S)),owners:Array<U32>,recipe:Tree.Recipe<LocalWorld(~S),Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),C.observe2(~S)>,debug:Bool,seen:LocalWorld(~S) & W.Reservation<S>) -> C.Session<S> & Maybe<&2,W.Handle<S>>:
  match seen:
    case (world,W.Reserved{handle}):(C.Session{LC.Installed{Build.Registered{world,owners,recipe,debug}},owner},Some{handle})
    case (world,_):(C.Session{LC.Installed{Build.Registered{world,owners,recipe,debug}},owner},None{})
def reserve_missing(~S:Data,app:C.Session<S>) -> C.Session<S> & Maybe<&2,W.Handle<S>>:
  match app:
    case C.Session{LC.Installed{Build.Registered{world,owners,recipe,debug}},owner}:reserved_missing(~S,owner,owners,recipe,debug,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,world))
def association_joined(~S:Data,localApp:C.CleanupApp(~S),peerOwner:System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S)),seen:System.Executed<C.CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S)),C.Args<S>,U32,A.QueueStatus>) -> C.Session<S> & (C.Session<S> & String):
  match seen:
    case System.RegistrationRejected{peerApp,localOwner,_}:(C.Session{localApp,localOwner},(C.Session{peerApp,peerOwner},"RegistrationRejected"))
    case System.Executed{peerApp,localOwner,_,_}:(C.Session{localApp,localOwner},(C.Session{peerApp,peerOwner},"UNEXPECTED_INVOCATION"))
def association(~S:Data,local:C.Session<S>,peer:C.Session<S>,target:W.Handle<S>) -> C.Session<S> & (C.Session<S> & String):
  match local peer:
    case C.Session{localApp,localOwner} C.Session{peerApp,peerOwner}:association_joined(~S,localApp,peerOwner,System.run_app(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S),~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~C.observe2(~S),~C.folded(~S),localOwner,peerApp,C.Args{target,X.Success{}}))
def done(~S:Data,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (_,text):head ++ "\nPEER_AFTER_MISSING\n" ++ text
def missing_after(~S:Data,peer:C.Session<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (_,text):done(~S,C.session_snapshot(~S,peer),head ++ "\nLOCAL_AFTER_MISSING\n" ++ text)
def missing_requested(~S:Data,peer:C.Session<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (local,text):missing_after(~S,peer,C.session_snapshot(~S,C.session_barrier(~S,local)),head ++ "\nMISSING=" ++ text)
def peer_foreign_after(~S:Data,local:C.Session<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (peer,text):missing_requested(~S,peer,C.session_invoke(~S,local,missing,X.Success{}),head ++ "\nPEER_AFTER_FOREIGN\n" ++ text)
def foreign_after(~S:Data,peer:C.Session<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (local,text):peer_foreign_after(~S,local,missing,C.session_snapshot(~S,peer),head ++ "\nLOCAL_AFTER_FOREIGN\n" ++ text)
def foreign_requested(~S:Data,peer:C.Session<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (local,text):foreign_after(~S,peer,missing,C.session_snapshot(~S,C.session_barrier(~S,local)),head ++ "\nFOREIGN=" ++ text)
def association_peer_after(~S:Data,local:C.Session<S>,+foreign:W.Handle<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (peer,text):foreign_requested(~S,peer,missing,C.session_invoke(~S,local,foreign,X.Success{}),head ++ "\nPEER_AFTER_REGISTRATION_REJECTION\n" ++ text)
def association_local_after(~S:Data,peer:C.Session<S>,+foreign:W.Handle<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (local,text):association_peer_after(~S,local,foreign,missing,C.session_snapshot(~S,peer),head ++ "\nLOCAL_AFTER_REGISTRATION_REJECTION\n" ++ text)
def association_returned(~S:Data,+foreign:W.Handle<S>,+missing:W.Handle<S>,seen:C.Session<S> & (C.Session<S> & String),head:String) -> String:
  match seen:
    case (local,(peer,status)):association_local_after(~S,peer,foreign,missing,C.session_snapshot(~S,local),head ++ "\nASSOCIATION=" ++ status)
def peer_before(~S:Data,local:C.Session<S>,+foreign:W.Handle<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (peer,text):association_returned(~S,foreign,missing,association(~S,local,peer,foreign),head ++ "\nPEER_BEFORE\n" ++ text)
def local_before(~S:Data,peer:C.Session<S>,+foreign:W.Handle<S>,+missing:W.Handle<S>,seen:C.Session<S> & String,head:String) -> String:
  match seen:
    case (local,text):peer_before(~S,local,foreign,missing,C.session_snapshot(~S,peer),head ++ "\nLOCAL_BEFORE\n" ++ text)
def identities(~S:Data,next:W.Factory,+foreign:W.Handle<S>,+missing:W.Handle<S>) -> String:
  match next foreign missing:
    case W.Factory{n} W.Handle{fns,fid} W.Handle{mns,mid}:"factoryNext=" ++ U32.show(n) ++ "|foreign=" ++ U32.show(fns) ++ ":" ++ U32.show(fid) ++ "|missing=" ++ U32.show(mns) ++ ":" ++ U32.show(mid)
def missing_ready(~S:Data,peer:C.Session<S>,+foreign:W.Handle<S>,next:W.Factory,seen:C.Session<S> & Maybe<&2,W.Handle<S>>) -> String:
  match seen:
    case (local,Some{+missing}):local_before(~S,peer,foreign,missing,C.session_snapshot(~S,local),identities(~S,next,foreign,missing))
    case _:"MISSING_RESERVATION_FAILURE"
def peer_ready(~S:Data,local:C.Session<S>,next:W.Factory,seen:C.Session<S> & Maybe<&2,W.Handle<S>>) -> String:
  match seen:
    case (peer,Some{foreign}):missing_ready(~S,peer,foreign,next,reserve_missing(~S,local))
    case _:"PEER_RESERVATION_FAILURE"
def peer_defined(~S:Data,local:C.Session<S>,next:W.Factory,+foreign:W.Handle<S>,seen:System.Defined<C.CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S))>) -> String:
  match seen:
    case System.Defined{app,owner}:peer_ready(~S,local,next,(C.Session{app,owner},Some{foreign}))
    case _:"PEER_REGISTRATION_FAILURE"
def peer_spawned(~S:Data,local:C.Session<S>,next:W.Factory,seen:LocalWorld(~S) & List<&2,W.Handle<S>>) -> String:
  match seen:
    case (world,Con{_,Con{_,Con{_,Con{foreign,Nil{}}}}}):peer_defined(~S,local,next,foreign,install(~S,world))
    case _:"PEER_SPAWN_FAILURE"
def peer_created(~S:Data,local:C.Session<S>,creation:W.Creation<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> String:
  match creation:
    case W.Created{next,world}:peer_spawned(~S,local,next,C.spawn(~S,4n,(world,[])))
    case _:"PEER_CREATE_FAILURE"
def local_defined(~S:Data,next:W.Factory,seen:System.Defined<C.CleanupApp(~S),System.Owner(~S,~O.Components<S>,~O.Resources,~U32,~C.declarations(~S),~C.clear(~S),~C.record(~S),~C.Args<S>,~U32,~A.QueueStatus,~C.body(~S))>) -> String:
  match seen:
    case System.Defined{app,owner}:peer_created(~S,C.Session{app,owner},W.create(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~C.empty(~S),next,O.Resources{Array.new(U32,0n,27),Array.new(U32,0n,28)}))
    case _:"LOCAL_REGISTRATION_FAILURE"
def local_spawned(~S:Data,next:W.Factory,seen:LocalWorld(~S) & List<&2,W.Handle<S>>) -> String:
  match seen:
    case (world,Con{_,Con{_,Con{_,Con{_,Nil{}}}}}):local_defined(~S,next,install(~S,world))
    case _:"LOCAL_SPAWN_FAILURE"
def local_created(~S:Data,creation:W.Creation<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>) -> String:
  match creation:
    case W.Created{next,world}:local_spawned(~S,next,C.spawn(~S,4n,(world,[])))
    case _:"LOCAL_CREATE_FAILURE"
def run(~S:Data) -> String:local_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~O.Resources,~A.Notice<S,U32>,~C.empty(~S),W.factory(),O.Resources{Array.new(U32,0n,17),Array.new(U32,0n,18)}))
def main() -> IO(Unit):IO.print("ForeignAlpha\n" ++ run(~C.Alpha) ++ "\nForeignBeta\n" ++ run(~C.Beta))
