import Base
import fixture-schema.bend as D
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/transaction.bend as X
import core-v1/src/ecs/commands.bend as Cmd
import core-v1/src/ecs/relation-commands.bend as A

type Staged<S:Data> is Type:
  Staged{tx:X.Tx<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,A.Notice<S,D.FixtureEvent>>,errors:String}
def related(~S:Data,errors:String,observed:X.Tx<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,A.Notice<S,D.FixtureEvent>> & A.QueueStatus) -> Staged<S>:
  match observed:
    case (tx,A.Queued{}):Staged{tx,errors}
    case (tx,A.MissingEntity{}):Staged{tx,errors ++ "relation-queue-refused;"}
def relate(~S:Data,staged:Staged<S>,source:W.Handle<S>,target:W.Handle<S>) -> Staged<S>:
  match staged:
    case Staged{tx,errors}:related(~S,errors,A.queue_relate(~S,~D.Components<S>,~D.Resources,~D.FixtureEvent,tx,D.link(~S),source,target))
def unrelate(~S:Data,staged:Staged<S>,source:W.Handle<S>) -> Staged<S>:
  match staged:
    case Staged{tx,errors}:related(~S,errors,A.queue_unrelate(~S,~D.Components<S>,~D.Resources,~D.FixtureEvent,tx,D.link(~S),source))
def begun(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Staged<S>:
  Staged{X.begin(~W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~A.Notice<S,D.FixtureEvent>,world),""}
def finished(~S:Data,errors:String,result:X.Returned<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,Unit>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match result:
    case X.Returned{world,X.Success{}}:(world,errors)
    case X.Returned{world,X.Failure{_}}:(world,errors ++ "unexpected-finish-failure;")
def commit(~S:Data,staged:Staged<S>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  match staged:
    case Staged{tx,errors}:finished(~S,errors,Cmd.tx_finish(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Unit,tx,X.Success{}))
# Actual command staging/commit precedes the separately observed real barrier.
def initial(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,+one:W.Handle<S>,+two:W.Handle<S>,three:W.Handle<S>,four:W.Handle<S>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  commit(~S,relate(~S,relate(~S,relate(~S,begun(~S,world),one,two),three,two),two,four))
def changed(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,one:W.Handle<S>,three:W.Handle<S>,four:W.Handle<S>) -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & String:
  commit(~S,unrelate(~S,relate(~S,begun(~S,world),one,four),three))
