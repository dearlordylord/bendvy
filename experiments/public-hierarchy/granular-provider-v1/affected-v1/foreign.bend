import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/affected-v1/foreign-observer.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
def factory_text(factory:W.Factory) -> String:
  match factory:
    case W.Factory{next}: U32.show(next)
def finish(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,before:String,peerBefore:String,lookup:String,after:String,identity:String) -> String:
  (_,peerAfter) = seen
  identity ++ "\nLOCAL_BEFORE\n" ++ before ++ "\nPEER_BEFORE\n" ++ peerBefore ++ "\n" ++ lookup ++ "\nLOCAL_AFTER\n" ++ after ++ "\nPEER_AFTER\n" ++ peerAfter
def local_after(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,peerNs:U32,before:String,peerBefore:String,lookup:String,identity:String) -> String:
  (_,after) = seen
  finish(~S,Obs.observe(~S,peerNs,peer),before,peerBefore,lookup,after,identity)
def lookup_done(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  (local,text)=seen
  local_after(~S,Obs.observe(~S,localNs,local),peer,peerNs,before,peerBefore,text,identity)
def dead_done(~S:Data,prefix:String,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  (local,text)=seen
  lookup_done(~S,(local,prefix ++ text ++ "\n"),peer,localNs,peerNs,before,peerBefore,identity)
def deactivated(~S:Data,prefix:String,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & W.Status,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  match result:
    case (local,W.Accepted{}):dead_done(~S,prefix,C.read(~S,local,W.Handle{localNs,1}),peer,localNs,peerNs,before,peerBefore,identity ++ "|deactivation=Accepted")
    case (local,_):lookup_done(~S,(local,prefix),peer,localNs,peerNs,before,peerBefore,identity ++ "|deactivation=Rejected")
def missing_done(~S:Data,prefix:String,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  (local,text)=seen
  deactivated(~S,prefix ++ text ++ "\n",W.deactivate(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,local,W.Handle{localNs,1}),peer,localNs,peerNs,before,peerBefore,identity)
def foreign_done(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  (local,text)=seen
  missing_done(~S,text ++ "\n",C.read(~S,local,W.Handle{localNs,99}),peer,localNs,peerNs,before,peerBefore,identity)
def peer_seen(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+localNs:U32,+peerNs:U32,foreign:W.Handle<S>,before:String,identity:String) -> String:
  (peer,peerBefore) = seen
  foreign_done(~S,C.read(~S,local,foreign),peer,localNs,peerNs,before,peerBefore,identity)
def local_seen(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localNs:U32,+peerNs:U32,foreign:W.Handle<S>,identity:String) -> String:
  (local,before) = seen
  peer_seen(~S,Obs.observe(~S,peerNs,peer),local,localNs,peerNs,foreign,before,identity)
def identified(~S:Data,localHandle:W.Handle<S>,peerHandle:W.Handle<S>,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory) -> String:
  match localHandle peerHandle:
    case W.Handle{+localNs,localId} W.Handle{+peerNs,+peerId}: local_seen(~S,Obs.observe(~S,localNs,local),peer,localNs,peerNs,W.Handle{peerNs,peerId},"target=" ++ U32.show(localNs) ++ ":" ++ U32.show(localId) ++ "|foreign=" ++ U32.show(peerNs) ++ ":" ++ U32.show(peerId) ++ "|factoryNext=" ++ factory_text(factory))
def peer_ready(~S:Data,handles:List<&2,W.Handle<S>>,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localHandle:W.Handle<S>,factory:W.Factory) -> String:
  match handles:
    case Con{_,Con{_,Con{_,Con{peerHandle,Nil{}}}}}: identified(~S,localHandle,peerHandle,local,peer,factory)
    case _: "PEER_LAYOUT_FAILURE"
def peer_spawned(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localHandle:W.Handle<S>,factory:W.Factory) -> String:
  (peer,handles) = seen
  peer_ready(~S,handles,local,peer,localHandle,factory)
def peer_created(~S:Data,creation:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localHandle:W.Handle<S>) -> String:
  match creation:
    case W.Created{factory,peer}: peer_spawned(~S,C.spawn(~S,4n,(peer,[])),local,localHandle,factory)
    case _: "PEER_CREATE_FAILURE"
def local_ready(~S:Data,handles:List<&2,W.Handle<S>>,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,factory:W.Factory) -> String:
  match handles:
    case Con{_,Con{_,Con{_,Con{localHandle,Nil{}}}}}: peer_created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~C.empty(~S),factory,Array.new(U32,0n,18)),local,localHandle)
    case _: "LOCAL_LAYOUT_FAILURE"
def local_spawned(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & List<&2,W.Handle<S>>,factory:W.Factory) -> String:
  (local,handles) = seen
  local_ready(~S,handles,local,factory)
def created(~S:Data,creation:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match creation:
    case W.Created{factory,local}: local_spawned(~S,C.spawn(~S,4n,(local,[])),factory)
    case _: "LOCAL_CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~C.empty(~S),W.factory(),Array.new(U32,0n,17)))
def main() -> IO(Unit):
  IO.print("HierarchyAlpha\n" ++ run(~C.Alpha) ++ "\nHierarchyBeta\n" ++ run(~C.Beta))
