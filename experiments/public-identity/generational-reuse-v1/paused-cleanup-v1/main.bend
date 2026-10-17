import Base
import fixture.bend as P
import observe.bend as O
import ../fixture.bend as F
import ../observe.bend as IdentityObserve
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-cleanup.bend as Cleanup

type Session<S:Data> is Type:
  Session{world:P.World(~S),namespace:U32,old:W.Handle<S>,replacement:Maybe<&2,W.Handle<S>>,frames:List<&2,G.CleanupFrame<S>>,log:String}
def maybe_handle(~S:Data,value:Maybe<&2,W.Handle<S>>) -> String:
  match value:
    case None{}:"none"
    case Some{handle}:F.handle_text(~S,handle)
def checkpoint_join(~S:Data,label:String,+namespace:U32,+old:W.Handle<S>,+replacement:Maybe<&2,W.Handle<S>>,+frames:List<&2,G.CleanupFrame<S>>,log:String,result:P.World(~S) & String) -> Session<S>:
  match result:
    case (world,text):Session{world,namespace,old,replacement,frames,log ++ label ++ ":{world={" ++ text ++ "};namespace=" ++ U32.show(namespace) ++ ";old=" ++ F.handle_text(~S,old) ++ ";replacement=" ++ maybe_handle(~S,replacement) ++ ";frames=" ++ O.frames(~S,frames) ++ "}\n"}
def checkpoint(~S:Data,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,namespace,old,replacement,frames,log}:checkpoint_join(~S,label,namespace,old,replacement,frames,log,O.world(~S,world))
def cleanup_result(~S:Data,namespace:U32,old:W.Handle<S>,replacement:Maybe<&2,W.Handle<S>>,log:String,result:Cleanup.CleanupResult<S,F.Store<S>,Array<U32>,F.Notice<S>>) -> Session<S>:
  match result:
    case Cleanup.Complete{world}:Session{world,namespace,old,replacement,[],log ++ "cleanup:Complete\n"}
    case Cleanup.Incomplete{world,frames}:Session{world,namespace,old,replacement,frames,log ++ "cleanup:Incomplete\n"}
def pause(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,+namespace,+old,replacement,_,log}:cleanup_result(~S,namespace,old,replacement,log,P.cleanup(~S,2n,[G.CleanupEnter{W.handle_key(~S,old)}],world,namespace))
def despawn_result(~S:Data,namespace:U32,old:W.Handle<S>,replacement:Maybe<&2,W.Handle<S>>,frames:List<&2,G.CleanupFrame<S>>,log:String,result:P.Tx(~S) & W.Status) -> Session<S>:
  match result:
    case (tx,status):Session{P.finish(~S,tx),namespace,old,replacement,frames,log ++ "separate-despawn:" ++ IdentityObserve.status(status) ++ "\n"}
def separate_despawn(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,namespace,+old,replacement,frames,log}:despawn_result(~S,namespace,old,replacement,frames,log,Cmd.tx_despawn_observed(~S,~P.Store(~S),~Array<U32>,~P.Notice(~S),~P.clear(~S),~P.record(~S),T.begin(~P.World(~S),~P.Notice(~S),world),old))
def barrier(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,namespace,old,replacement,frames,log}:Session{W.barrier(~S,~P.Store(~S),~Array<U32>,~P.Notice(~S),world),namespace,old,replacement,frames,log}
def spawned(~S:Data,namespace:U32,old:W.Handle<S>,frames:List<&2,G.CleanupFrame<S>>,log:String,result:P.World(~S) & Maybe<&2,W.Handle<S>>) -> Session<S>:
  match result:
    case (world,replacement):Session{world,namespace,old,replacement,frames,log}
def reuse(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,namespace,old,_,frames,log}:spawned(~S,namespace,old,frames,log,P.spawn(~S,world,200))
def resume(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,+namespace,old,replacement,frames,log}:cleanup_result(~S,namespace,old,replacement,log,Cleanup.units(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~P.component_clear(~S),~P.record(~S),1n,Cleanup.Incomplete{world,frames},namespace,[]))
def read_result(~S:Data,namespace:U32,old:W.Handle<S>,replacement:Maybe<&2,W.Handle<S>>,frames:List<&2,G.CleanupFrame<S>>,log:String,result:P.World(~S) & C.Access<U32>) -> Session<S>:
  match result:
    case (world,C.Found{value}):Session{world,namespace,old,replacement,frames,log ++ "replacement-read:" ++ U32.show(value) ++ "\n"}
    case (world,C.MissingEntity{}):Session{world,namespace,old,replacement,frames,log ++ "replacement-read:MissingEntity\n"}
    case (world,C.ComponentAbsent{}):Session{world,namespace,old,replacement,frames,log ++ "replacement-read:Absent\n"}
def read(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,namespace,old,None{},frames,log}:Session{world,namespace,old,None{},frames,log ++ "replacement-read:no-receipt\n"}
    case Session{world,namespace,old,Some{+handle},frames,log}:read_result(~S,namespace,old,Some{handle},frames,log,C.get(~S,~P.Store(~S),~Array<U32>,~P.Notice(~S),~P.Rest<S>,~Array<U32>,~U32,~Unit,~P.take(~S),~P.put(~S),~F.view,P.family(~S),world,handle))
def steps(~S:Data,session:Session<S>) -> Session<S>:
  session=checkpoint(~S,"original-live",session)
  session=checkpoint(~S,"paused-actual-finish",pause(~S,session))
  session=checkpoint(~S,"separate-cleanup-queued",separate_despawn(~S,session))
  session=checkpoint(~S,"old-cleared-and-released",barrier(~S,session))
  session=checkpoint(~S,"new-generation-pending",reuse(~S,session))
  session=checkpoint(~S,"new-generation-live-before-resume",barrier(~S,session))
  session=checkpoint(~S,"retained-stale-finish-resumed",resume(~S,session))
  checkpoint(~S,"new-generation-read-preserved",read(~S,session))
def rendered(~S:Data,session:Session<S>) -> String:
  match session:
    case Session{_,_,_,_,_,log}:log
def named(~S:Data,old:W.Handle<S>,result:P.World(~S) & U32) -> String:
  match result:
    case (world,namespace):rendered(~S,steps(~S,Session{world,namespace,old,None{},[],""}))
def started(~S:Data,result:P.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match result:
    case (_,None{}):"initial-spawn-refused"
    case (world,Some{old}):named(~S,old,W.namespace(~S,~P.Store(~S),~Array<U32>,~P.Notice(~S),W.barrier(~S,~P.Store(~S),~Array<U32>,~P.Notice(~S),world)))
def created(result:WI.Creation<F.Workshop,P.Store(~F.Workshop),Array<U32>,P.Notice(~F.Workshop)>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("creation-refused")
    case WI.Created{world}:IO.print(started(~F.Workshop,P.spawn(~F.Workshop,world,100)))
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.Workshop,P.Store(~F.Workshop),Array<U32>,P.Notice(~F.Workshop)>,Unit,WI.create(~F.Workshop,~P.Store(~F.Workshop),~Array<U32>,~P.Notice(~F.Workshop),~P.empty(~F.Workshop),ANode{ALeaf{61},ALeaf{62}}),created)
