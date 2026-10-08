import Base
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A
import gated-core/system.bend as Sys
import gated-core/schedule.bend as Sch

# Reached registered runner returns a marker; condition false cannot return it.
def runner(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,args:Unit) -> Sys.Outcome<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,String,U32>:
  Sys.Succeeded{world,1}
type Holder<S:Data> is Type:
  Holder{registry:Sys.Registry<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Unit,String,U32,runner(~S)>,bodyMarkers:U32}
def dispatched(~S:Data,count:U32,result:Sys.RunResult<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Unit,String,U32,runner(~S)>) -> Holder<S> & Sys.Outcome<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,String,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,marker}}:(Holder{registry,(count + marker : U32)},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Holder{registry,count},Sys.Failed{world,error})
    case Sys.RegistrationRejected{registry,world,_}:(Holder{registry,count},Sys.Failed{world,"registration-rejected"})
def dispatch(~S:Data,holder:Holder<S>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,id:U32) -> Holder<S> & Sys.Outcome<W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,String,Unit>:
  match holder:
    case Holder{registry,count}:dispatched(~S,count,Sys.run(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Unit,~String,~U32,~runner(~S),registry,world,Unit{}))
def run(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,schedule:Sch.Schedule<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Holder<S>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Sch.RunResult<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Holder<S>,String>:
  Sch.run(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Holder<S>,~String,~dispatch(~S),~condition,schedule,world)
