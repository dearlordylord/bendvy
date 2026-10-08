import Base
import gated-runner.bend as Run
import gated-core/system.bend as Sys
import gated-core/schedule.bend as Sch
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A

type Completed<S:Data> is Type:
  Completed{result:Sch.RunResult<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>,String>,earlier:List<&2,Sch.Observation>}
  Refused{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,owners:Maybe<&1,Run.Holder<S>>,error:String}
def false_built(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,earlier:List<&2,Sch.Observation>,result:Sch.Build<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>>) -> Completed<S>:
  match result:
    case Sch.Built{schedule}:Completed{Run.run(~S,~condition,schedule,world),earlier}
    case Sch.Invalid{owners}:Refused{world,Some{owners},"false-plan-refused"}
def true_done(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,+id:U32,result:Sch.RunResult<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>,String>) -> Completed<S>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,_,_,owners},world,observations}:false_built(~S,~condition,world,observations,Sch.build(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Run.Holder<S>,namespace,"check-false",[Sch.System{id,2}],[id],owners))
    case result:Completed{result,[]}
def true_built(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,+id:U32,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,result:Sch.Build<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Run.Holder<S>>) -> Completed<S>:
  match result:
    case Sch.Built{schedule}:true_done(~S,~condition,id,Run.run(~S,~condition,schedule,world))
    case Sch.Invalid{owners}:Refused{world,Some{owners},"true-plan-refused"}
def named(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,+id:U32,holder:Run.Holder<S>,result:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> Completed<S>:
  (world,namespace)=result
  true_built(~S,~condition,id,world,Sch.build(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Run.Holder<S>,namespace,"check-true",[Sch.System{id,1}],[id],holder))
def identified(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,result:Sys.Registry<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Unit,String,U32,Run.runner(~S)> & U32) -> Completed<S>:
  (registry,id)=result
  named(~S,~condition,id,Run.Holder{registry,0},W.namespace(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
def registered(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,result:Sys.RegistrationResult<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>,Unit,String,U32,Run.runner(~S)>) -> Completed<S>:
  match result:
    case Sys.Registered{world,registry}:identified(~S,~condition,world,Sys.identity(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Unit,~String,~U32,~Run.runner(~S),registry))
    case Sys.RegistrationFailed{world}:Refused{world,None{},"registration-refused"}
def run(~S:Data,~condition:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> -> U32 -> W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & Bool,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> Completed<S>:
  registered(~S,~condition,Sys.register(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,~Unit,~String,~U32,~Run.runner(~S),world,"relation-check-body",[]))
