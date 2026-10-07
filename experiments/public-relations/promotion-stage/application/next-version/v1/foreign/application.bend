import Base
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/transaction.bend as X
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/relation-commands.bend as A
import ../../../../../../../src/ecs/relation-providers.bend as P
import owned-world.bend as O
import query-client.bend as Q
import cleanup-client.bend as C

type WorldPair<S:Data> is Type:
  WorldPair{local:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,peer:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,localHandle:W.Handle<S>,peerHandle:W.Handle<S>,text:String}

def body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)

def activated(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Status,handle:W.Handle<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  (world,_) = result
  (O.spawn(~S,4n,world),handle)

def first(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Reservation<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  match result:
    case (world,W.Reserved{+handle}): activated(~S,W.activate(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,handle),handle)
    case (world,_): (world,W.Handle{0,0})

def seeded(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>:
  first(~S,W.reserve_id(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world))

def fields(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  (world,text ++ "fields=" ++ value ++ "\n")

def queried(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,name:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  fields(~S,C.observe(~S,world),name ++ "\n" ++ value)

def observed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+name:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  queried(~S,Q.registered_world(~S,world,"observe-" ++ name),name)

def peer_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,local:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>,ph:W.Handle<S>,text:String) -> WorldPair<S>:
  (peer,value) = result
  WorldPair{local,peer,lh,ph,text ++ value}

def local_observed(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,peer:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>,ph:W.Handle<S>,text:String,phase:String) -> WorldPair<S>:
  (local,value) = result
  peer_observed(~S,observed(~S,peer,"peer-" ++ phase),local,lh,ph,text ++ value)

def observe(~S:Data,pair:WorldPair<S>,+phase:String) -> WorldPair<S>:
  match pair:
    case WorldPair{local,peer,lh,ph,text}: local_observed(~S,observed(~S,local,"local-" ++ phase),peer,lh,ph,text,phase)

def status_text(status:A.QueueStatus) -> String:
  match status:
    case A.Queued{}: "Queued"
    case A.MissingEntity{}: "MissingEntity"

def rejected(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus,peer:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>,ph:W.Handle<S>,text:String) -> WorldPair<S>:
  (tx,status) = result
  WorldPair{O.commit(~S,tx,X.Success{}),peer,lh,ph,text ++ "frontend=" ++ status_text(status) ++ "\n"}

def pending(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus,peer:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>,+ph:W.Handle<S>,text:String,+namespace:U32) -> WorldPair<S>:
  (tx,_) = result
  rejected(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~Q.link(~S),~A.QueueStatus,~body(~S),P.Targets{W.Handle{namespace,2},ph},tx),peer,lh,ph,text)

def queue(~S:Data,pair:WorldPair<S>) -> WorldPair<S>:
  match pair:
    case WorldPair{local,peer,+lh,+ph,text}:
      match lh:
        case W.Handle{+namespace,id}: pending(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~Q.link(~S),~A.QueueStatus,~body(~S),P.Targets{W.Handle{namespace,3},W.Handle{namespace,id}},X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,local)),peer,lh,ph,text,namespace)

def barrier(~S:Data,pair:WorldPair<S>) -> WorldPair<S>:
  match pair:
    case WorldPair{local,peer,lh,ph,text}: WorldPair{W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,local),peer,lh,ph,text}

def finish(~S:Data,pair:WorldPair<S>) -> String:
  match pair:
    case WorldPair{_,_,_,_,text}: text

def paired(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>,local:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>) -> String:
  (peer,ph) = result
  finish(~S,observe(~S,barrier(~S,observe(~S,queue(~S,observe(~S,WorldPair{local,peer,lh,ph,""},"before")),"queued")),"applied"))

def second(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,local:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,lh:W.Handle<S>) -> String:
  match result:
    case W.Created{_,peer}: paired(~S,seeded(~S,peer),local,lh)
    case _: "SECOND_REJECTED"

def local_seeded(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & W.Handle<S>,factory:W.Factory) -> String:
  (local,lh) = result
  second(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.empty(~S),factory,77),local,lh)

def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{factory,local}: local_seeded(~S,seeded(~S,local),factory)
    case _: "FIRST_REJECTED"

def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.empty(~S),W.factory(),77))

def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
