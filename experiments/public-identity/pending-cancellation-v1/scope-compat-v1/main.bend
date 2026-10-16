import Base
import ./fixture.bend as F
import ../main.bend as Dump
import /tmp/bendvy-pending-cancellation/src/ecs/world.bend as W
import /tmp/bendvy-pending-cancellation/src/ecs/commands.bend as Cmd
import /tmp/bendvy-pending-cancellation/src/ecs/transaction.bend as T
import /tmp/bendvy-pending-cancellation/src/ecs/lifetime-scope.bend as Sc
import /tmp/bendvy-pending-cancellation/src/ecs/lifetime-scope-world-spawn.bend as Spawn
import /tmp/bendvy-pending-cancellation/src/ecs/relation-commands.bend as A
import /tmp/bendvy-pending-cancellation/src/ecs/relation-types.bend as G

type Scene is Data:Scene{}
def Store() -> Type:A.Store<Scene,Sc.Store<Scene,F.Components>>
def World() -> Type:W.World<Scene,Store(),Array<U32>,A.Notice<Scene,U32>>
def Tx() -> Type:T.Tx<World(),A.Notice<Scene,U32>>
type Session is Type:Session{world:World(),scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>}
type Working is Type:Working{tx:Tx(),scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>}
def empty(_:Unit) -> Store():A.Store{Sc.Store{F.Components{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},[]},[]},G.Graph{[],[]}}
def populated(removed:List<F.Payload>,seen:Array<Maybe<&1,F.Payload>> & Maybe<&1,F.Payload>) -> F.Components:
  match seen:
    case (slots,None{}):F.Components{slots,removed}
    case (slots,Some{old}):F.Components{slots,old <> removed}
def populate(components:F.Components,handle:W.Handle<Scene>,payload:F.Payload) -> F.Components:
  match components handle:
    case F.Components{slots,removed} W.Handle{_,id}:populated(removed,Array.swap(Maybe<&1,F.Payload>,slots,id,Some{payload}))
def plain_store(store:Store(),handle:W.Handle<Scene>,payload:F.Payload) -> Store() & Unit:
  match store:
    case A.Store{Sc.Store{components,members},graph}:(A.Store{Sc.Store{populate(components,handle,payload),members},graph},Unit{})
def plain_done(seen:World() & Unit) -> World():
  match seen:
    case (world,_):world
def plain(world:World(),handle:W.Handle<Scene>,payload:F.Payload) -> World():plain_done(W.with_store(~Scene,~Store(),~Array<U32>,~A.Notice<Scene,U32>,~Unit,store => plain_store(store,handle,payload),world))
def view_done(label:String,+scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>,seen:World() & String) -> Session:
  (world,text)=seen
  Session{world,scope,List.append(&2,String,rows,[label ++ ":" ++ text]),handles}
def view(label:String,value:Session) -> Session:
  match value:
    case Session{world,scope,rows,handles}:view_done(label,scope,rows,handles,F.observe(~Scene,world))
def tx_view_done(label:String,+scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>,+events:List<&2,A.Notice<Scene,U32>>,a:World() & String,b:List<(World() -> World())> & Nat,c:List<(World() -> World())> & Nat) -> Working:
  (world,text)=a
  (undo,uc)=b
  (commands,cc)=c
  Working{T.Tx{world,undo,commands,events},scope,List.append(&2,String,rows,[label ++ ":undo=" ++ Nat.show(uc) ++ ";commands=" ++ Nat.show(cc) ++ ";events=" ++ List.show(&2,A.Notice<Scene,U32>,F.show_notice(~Scene),events) ++ ";" ++ text]),handles}
def tx_view(label:String,value:Working) -> Working:
  match value:
    case Working{T.Tx{world,undo,commands,events},scope,rows,handles}:tx_view_done(label,scope,rows,handles,events,F.observe(~Scene,world),Dump.callbacks(~World(),undo),Dump.callbacks(~World(),commands))
def begin(value:Session) -> Working:
  match value:
    case Session{world,scope,rows,handles}:Working{T.begin(~World(),~A.Notice<Scene,U32>,world),scope,rows,handles}
def spawned(+scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>,seen:Tx() & Sc.SpawnResult<Scene,F.Payload>) -> Working:
  match seen:
    case (tx,Sc.Spawned{+handle}):Working{tx,scope,List.append(&2,String,rows,["spawned=" ++ Dump.handle(~Scene,handle)]),List.append(&2,W.Handle<Scene>,handles,[handle])}
    case (tx,Sc.SpawnRejected{_,_}):Working{tx,scope,List.append(&2,String,rows,["unexpected-spawn-refusal"]),handles}
def spawn_component(value:Working) -> Working:
  match value:
    case Working{tx,+scope,rows,handles}:spawned(scope,rows,handles,Sc.tx_spawn_in(~Scene,~F.Components,~Array<U32>,~U32,~F.Payload,~populate,tx,scope,F.payload(1)))
def spawn_world(value:Working) -> Working:
  match value:
    case Working{tx,+scope,rows,handles}:spawned(scope,rows,handles,Spawn.tx_spawn_in(~Scene,~F.Components,~Array<U32>,~U32,~F.Payload,~plain,tx,scope,F.payload(2)))
def finished(+scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>,seen:T.Returned<World(),Unit>) -> Session:
  match seen:
    case T.Returned{world,_}:Session{world,scope,rows,handles}
def finish(value:Working) -> Session:
  match value:
    case Working{tx,scope,rows,handles}:finished(scope,rows,handles,Cmd.tx_finish(~Scene,~Store(),~Array<U32>,~A.Notice<Scene,U32>,~Unit,tx,T.Success{}))
def barrier(value:Session) -> Session:
  match value:
    case Session{world,scope,rows,handles}:view("barrier",Session{W.barrier(~Scene,~Store(),~Array<U32>,~A.Notice<Scene,U32>,world),scope,rows,handles})
def cleanup_returned(+scope:Sc.Scope<Scene>,rows:List<&2,String>,handles:List<&2,W.Handle<Scene>>,seen:Tx() & A.QueueStatus) -> Working:
  match seen:
    case (tx,A.Queued{}):Working{tx,scope,List.append(&2,String,rows,["cleanup=Queued"]),handles}
    case (tx,A.MissingEntity{}):Working{tx,scope,List.append(&2,String,rows,["cleanup=MissingEntity"]),handles}
def cleanup(value:Working) -> Working:
  match value:
    case Working{tx,+scope,rows,handles}:cleanup_returned(scope,rows,handles,Sc.tx_cleanup(~Scene,~F.Components,~Array<U32>,~U32,~F.clear(~Scene),~F.record(~Scene),~[],tx,scope))
def spawn_both(value:Session) -> Session:
  barrier(view("spawn-committed",finish(tx_view("both-producers-staged",spawn_world(tx_view("component-producer-staged",spawn_component(begin(view("created",value)))))))))
def run(value:Session) -> Session:
  barrier(view("cleanup-committed",finish(tx_view("cleanup-staged",cleanup(begin(spawn_both(value)))))))
def render(value:Session) -> String:
  match value:
    case Session{_,Sc.Scope{ns,name},rows,handles}:"scope{" ++ U32.show(ns) ++ ":" ++ name ++ "};rows=" ++ List.show(&2,String,x=>x,rows) ++ ";handles=" ++ List.show(&2,W.Handle<Scene>,Dump.handle(~Scene),handles)
def scoped(seen:World() & Sc.Scope<Scene>) -> String:
  match seen:
    case (world,+scope):render(run(Session{world,scope,[],[]}))
def created(seen:W.Creation<Scene,Store(),Array<U32>,A.Notice<Scene,U32>>) -> String:
  match seen:
    case W.Created{_,world}:scoped(Sc.scope(~Scene,~F.Components,~Array<U32>,~U32,world,"room"))
    case W.CreateRejected{_,_}:"unexpected-creation-refusal"
def main() -> IO(Unit):IO.print(created(W.create(~Scene,~Store(),~Array<U32>,~A.Notice<Scene,U32>,~empty,W.factory(),Dump.pair(900))))
