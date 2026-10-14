import Base
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/relation-commands.bend as A
import ./fixture.bend as F

type Scene is Data:
  Scene{}
def empty(unit:Unit) -> A.Store<Scene,Sc.Store<Scene,F.Components>>:
  A.empty(~Scene,~Sc.Store<Scene,F.Components>,Sc.empty(~Scene,~F.Components,F.Components{ANode{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}}},[]}))
def created(creation:W.Creation<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  match creation:
    case W.Created{_,world}:world
    case W.CreateRejected{_,resource}:W.World{0,1,0,ALeaf{False{}},1,0n,empty(Unit{}),resource,[],[],[],1,0}
def populated(removed:List<F.Payload>,seen:Array<Maybe<&1,F.Payload>> & Maybe<&1,F.Payload>) -> F.Components:
  match seen:
    case (slots,None{}):F.Components{slots,removed}
    case (slots,Some{old}):F.Components{slots,old <> removed}
def populate(components:F.Components,handle:W.Handle<Scene>,payload:F.Payload) -> F.Components:
  match components handle:
    case F.Components{slots,removed} W.Handle{_,id}:populated(removed,Array.swap(Maybe<&1,F.Payload>,slots,id,Some{payload}))
def plain_store(store:A.Store<Scene,Sc.Store<Scene,F.Components>>,handle:W.Handle<Scene>,payload:F.Payload) -> A.Store<Scene,Sc.Store<Scene,F.Components>> & Unit:
  match store:
    case A.Store{Sc.Store{components,members},graph}:(A.Store{Sc.Store{populate(components,handle,payload),members},graph},Unit{})
def plain_done(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & Unit) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  match seen:
    case (world,_):world
def plain(world:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,handle:W.Handle<Scene>,payload:F.Payload) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  plain_done(W.with_store(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~Unit,store => plain_store(store,handle,payload),world))
def scoped_returned(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & Sc.SpawnResult<Scene,F.Payload>) -> T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>:
  match seen:
    case (tx,Sc.Spawned{handle}):(tx,handle)
    case (tx,Sc.SpawnRejected{_,_}):(tx,W.Handle{0,0})
def plain_returned(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Reservation<Scene>) -> T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>:
  match seen:
    case (tx,W.Reserved{handle}):(tx,handle)
    case (tx,W.ReservationRejected{_}):(tx,W.Handle{0,0})
def related(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & A.QueueStatus) -> T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>>:
  match seen:
    case (tx,_):tx
def committed(seen:T.Returned<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,Unit>) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  match seen:
    case T.Returned{world,_}:world
def finish(tx:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>>) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  committed(Cmd.tx_finish(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~Unit,tx,T.Success{}))
def cleanup(world:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,scope:Sc.Scope<Scene>) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>:
  finish(related(Sc.tx_cleanup(~Scene,~F.Components,~Array<U32>,~U32,~F.clear(~Scene),~F.record(~Scene),~F.descriptors(~Scene),T.begin(~W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,~A.Notice<Scene,U32>,world),scope)))
def observed(label:String,seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String:
  match seen:
    case (world,text):(world,"{\"label\":\"" ++ label ++ "\",\"world\":\"" ++ text ++ "\"}")
def observe(label:String,world:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>) -> W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String:
  observed(label,F.observe(~Scene,world))
def end(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String,a:String,b:String,c:String,d:String) -> String:
  match seen:
    case (_,e):"[" ++ a ++ "," ++ b ++ "," ++ c ++ "," ++ d ++ "," ++ e ++ "]"
def cleaned(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String,scene:Sc.Scope<Scene>,a:String,b:String,c:String) -> String:
  match seen:
    case (world,d):end(observe("repeated-clean",W.barrier(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,cleanup(world,scene))),a,b,c,d)
def pending_clean(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String,scene:Sc.Scope<Scene>,a:String,b:String) -> String:
  match seen:
    case (world,c):cleaned(observe("cleaned",W.barrier(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,world)),scene,a,b,c)
def spawned(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String,+scene:Sc.Scope<Scene>,a:String) -> String:
  match seen:
    case (world,b):pending_clean(observe("pending-clean",cleanup(world,scene)),scene,a,b)
def pending_spawn(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & String,scene:Sc.Scope<Scene>) -> String:
  match seen:
    case (world,a):spawned(observe("spawned",W.barrier(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,world)),scene,a)
def spawn6(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,+h1:W.Handle<Scene>,+h2:W.Handle<Scene>,+h3:W.Handle<Scene>,+h4:W.Handle<Scene>) -> String:
  match seen:
    case (tx,_):pending_spawn(observe("pending-spawn",finish(related(A.queue_relate(~Scene,~Sc.Store<Scene,F.Components>,~Array<U32>,~U32,related(A.queue_relate(~Scene,~Sc.Store<Scene,F.Components>,~Array<U32>,~U32,related(A.queue_relate(~Scene,~Sc.Store<Scene,F.Components>,~Array<U32>,~U32,tx,F.parent(~Scene),h2,h1)),F.parent(~Scene),h4,h2)),F.link(~Scene),h3,h1)))),scene)
def spawn5(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,+h1:W.Handle<Scene>,+h2:W.Handle<Scene>,+h3:W.Handle<Scene>,+h4:W.Handle<Scene>) -> String:
  match seen:
    case (tx,_):spawn6(plain_returned(Cmd.tx_spawn(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~F.Payload,~plain,tx,F.payload(6))),scene,h1,h2,h3,h4)
def spawn4(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,same:Sc.Scope<Scene>,+h1:W.Handle<Scene>,+h2:W.Handle<Scene>,+h3:W.Handle<Scene>) -> String:
  match seen:
    case (tx,+h4):spawn5(scoped_returned(Sc.tx_spawn_in(~Scene,~F.Components,~Array<U32>,~U32,~F.Payload,~populate,tx,same,F.payload(5))),scene,h1,h2,h3,h4)
def spawn3(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,same:Sc.Scope<Scene>,+h1:W.Handle<Scene>,+h2:W.Handle<Scene>) -> String:
  match seen:
    case (tx,+h3):spawn4(plain_returned(Cmd.tx_spawn(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~F.Payload,~plain,tx,F.payload(4))),scene,same,h1,h2,h3)
def spawn2(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,same:Sc.Scope<Scene>,+h1:W.Handle<Scene>) -> String:
  match seen:
    case (tx,+h2):spawn3(plain_returned(Cmd.tx_spawn(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~F.Payload,~plain,tx,F.payload(3))),scene,same,h1,h2)
def spawn1(seen:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & W.Handle<Scene>,scene:Sc.Scope<Scene>,same:Sc.Scope<Scene>) -> String:
  match seen:
    case (tx,+h1):spawn2(plain_returned(Cmd.tx_spawn(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~F.Payload,~plain,tx,F.payload(2))),scene,same,h1)
def same_scope(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & Sc.Scope<Scene>,+scene:Sc.Scope<Scene>) -> String:
  match seen:
    case (world,same):spawn1(scoped_returned(Sc.tx_spawn_in(~Scene,~F.Components,~Array<U32>,~U32,~F.Payload,~populate,T.begin(~W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>>,~A.Notice<Scene,U32>,world),scene,F.payload(1))),scene,same)
def first_scope(seen:W.World<Scene,A.Store<Scene,Sc.Store<Scene,F.Components>>,Array<U32>,A.Notice<Scene,U32>> & Sc.Scope<Scene>) -> String:
  match seen:
    case (world,+scene):same_scope(Sc.scope(~Scene,~F.Components,~Array<U32>,~U32,world,"scene"),scene)
def run(unit:Unit) -> String:
  first_scope(Sc.scope(~Scene,~F.Components,~Array<U32>,~U32,created(W.create(~Scene,~A.Store<Scene,Sc.Store<Scene,F.Components>>,~Array<U32>,~A.Notice<Scene,U32>,~empty,W.factory(),ANode{ALeaf{77},ALeaf{88}})),"scene"))
def main() -> IO(Unit):
  IO.print(run(Unit{}))
