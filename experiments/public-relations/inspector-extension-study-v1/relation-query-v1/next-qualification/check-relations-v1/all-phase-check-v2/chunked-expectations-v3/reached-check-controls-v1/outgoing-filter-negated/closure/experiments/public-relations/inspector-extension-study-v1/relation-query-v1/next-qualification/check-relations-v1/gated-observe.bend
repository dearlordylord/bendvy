import Base
import gated-plan.bend as Gate
import gated-runner.bend as Run
import gated-core/schedule.bend as Sch
import fixture-snapshot.bend as Snap
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/check.bend as K
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A

type Record<S:Data> is Data:
  Record{before:Snap.Snapshot<S>,after:Snap.Snapshot<S>,bodyMarkers:U32,allowed:List<&2,Sch.Observation>,skipped:List<&2,Sch.Observation>}
type Observed<S:Data> is Type:
  Finished{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,schedule:Sch.Schedule<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>>,record:Record<S>}
  Refused{before:Snap.Snapshot<S>,result:Gate.Completed<S>}
def after(~S:Data,before:Snap.Snapshot<S>,bodyMarkers:U32,allowed:List<&2,Sch.Observation>,skipped:List<&2,Sch.Observation>,schedule:Sch.Schedule<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>>,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> Observed<S>:
  match result:
    case (K.Frame{world},last):Finished{world,schedule,Record{before,last,bodyMarkers,allowed,skipped}}
def completed(~S:Data,before:Snap.Snapshot<S>,result:Gate.Completed<S>) -> Observed<S>:
  match result:
    case Gate.Completed{Sch.Finished{Sch.Schedule{namespace,name,steps,Run.Holder{registry,+markers}},world,skipped},allowed}:after(~S,before,markers,allowed,skipped,Sch.Schedule{namespace,name,steps,Run.Holder{registry,markers}},Snap.observe(~S,K.Frame{world}))
    case result:Refused{before,result}
def before(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,result:K.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Snap.Snapshot<S>) -> Observed<S>:
  match result:
    case (K.Frame{world},first):completed(~S,first,Gate.run(~S,~condition,world))
def run(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Observed<S>:
  before(~S,~condition,Snap.observe(~S,K.Frame{world}))
