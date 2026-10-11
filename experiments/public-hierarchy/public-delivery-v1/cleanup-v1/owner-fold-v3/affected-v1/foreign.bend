import Base
import ../consumer.bend as C
import ../../../owners.bend as O
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-hierarchy/public-delivery-v1/affected-v1/foreign-observer.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/relation-cleanup.bend as Cleanup
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
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
def show_descriptors(~S:Data,xs:List<&2,G.Descriptor<S>>) -> String:
  match xs:
    case Nil{}: ""
    case Con{descriptor,rest}: Obs.show_descriptor(~S,descriptor) ++ ";" ++ show_descriptors(~S,rest)
def show_frame(~S:Data,frame:G.CleanupFrame<S>) -> String:
  match frame:
    case G.CleanupEnter{id}: "Enter:" ++ U32.show(id)
    case G.CleanupDescriptors{id,remaining}: "Descriptors:" ++ U32.show(id) ++ ":[" ++ show_descriptors(~S,remaining) ++ "]"
    case G.CleanupChildren{id,descriptor,remaining,children}: "Children:" ++ U32.show(id) ++ ":" ++ Obs.show_descriptor(~S,descriptor) ++ ":[" ++ show_descriptors(~S,remaining) ++ "]:[" ++ O.show_ids(children) ++ "]"
    case G.CleanupFinish{id}: "Finish:" ++ U32.show(id)
def show_frames(~S:Data,frames:List<&2,G.CleanupFrame<S>>) -> String:
  match frames:
    case Nil{}: ""
    case Con{frame,rest}: show_frame(~S,frame) ++ ";" ++ show_frames(~S,rest)
def lookup_done(~S:Data,seen:Cleanup.CleanupResult<S,O.Components<S>,Array<U32>,U32>,peer:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localNs:U32,peerNs:U32,before:String,peerBefore:String,identity:String) -> String:
  match seen:
    case Cleanup.Complete{local}: local_after(~S,Obs.observe(~S,localNs,local),peer,peerNs,before,peerBefore,"cleanup=Complete",identity)
    case Cleanup.Incomplete{local,frames}: local_after(~S,Obs.observe(~S,localNs,local),peer,peerNs,before,peerBefore,"cleanup=Incomplete|frames=" ++ show_frames(~S,frames),identity)
def peer_seen(~S:Data,seen:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,local:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,localNs:U32,+peerNs:U32,foreign:W.Handle<S>,before:String,identity:String) -> String:
  (peer,peerBefore) = seen
  lookup_done(~S,Cleanup.automatic(~S,~O.Components<S>,~Array<U32>,~U32,~C.clear(~S),~C.despawn_notice(~S),local,foreign,[C.parent(~S),C.link(~S)]),peer,localNs,peerNs,before,peerBefore,identity)
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
