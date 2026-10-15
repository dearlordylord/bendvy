import Base
import main.bend as Main
import ../provider.bend as P
import fixture.bend as F
import systems.bend as Systems
import observer.bend as Observer
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../../src/ecs/ordinary-app-schedule-description.bend as Named
import ../../../../../src/ecs/ordinary-condition-composition.bend as Comp
import ../../../../../src/ecs/schedule.bend as Sch
import ../../../../../src/ecs/schedule-provision.bend as SP

type Run<S:Data> is Type:
  Run{app:Main.app_type(S),observations:List<&2,Sch.Observation>,status:String}

def error(value:Comp.Error<String>) -> String:
  match value:
    case Comp.SystemError{error}:"system-error:" ++ error
    case Comp.ConditionRegistrationRejected{}:"condition-registration-rejected"
    case Comp.ConditionUnavailable{}:"condition-unavailable"
def run_result(~S:Data,value:Main.run_result_type(~S)) -> Run<S>:
  match value:
    case Schedule.Finished{app,observations}:Run{app,observations,"finished"}
    case Schedule.Failed{app,failure,observations}:Run{app,observations,error(failure)}
    case Schedule.Rejected{app}:Run{app,[],"rejected"}
    case Schedule.Missing{app,requirements}:Run{app,[],"missing(" ++ Observer.requirements(~S,requirements) ++ ")"}

def world_text(~S:Data,app:Main.app_type(~S),owners_text:String,guards_text:String,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,rendered:String) -> Main.app_type(~S) & String:
  (app,prior ++ label ++ ":status=" ++ status ++ ";schedule=" ++ Observer.schedule_observations(observations) ++ ";owners=" ++ owners_text ++ ";conditions=" ++ guards_text ++ ";debug=" ++ rendered ++ "\n")
def app_snapshot_returned(~S:Data,owners_text:String,guards_text:String,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,result:Main.app_type(~S) & Maybe<&2,Named.ConditionedDescription<S,String>>) -> Main.app_type(~S) & String:
  match result:
    case (app,description):world_text(~S,app,owners_text,guards_text,status,observations,prior,label,Observer.debug(~S,description))
def app_snapshot(~S:Data,app:Main.app_type(~S),owners_text:String,guards_text:String,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String) -> Main.app_type(~S) & String:
  app_snapshot_returned(~S,owners_text,guards_text,status,observations,prior,label,Named.snapshot_conditions(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Systems.Owners<S>,~String,~Observer.observe(~S),~Observer.fold(~S),~Main.condition_owner_type(~S),~Main.condition_eval(~S),app))
def make_registered(~S:Data,world:W.World<S,P.Store<S>,F.Resources<S>,Unit>,owners:Systems.Owners<S>,recipe:Tree.Recipe<W.World<S,P.Store<S>,F.Resources<S>,Unit>,String,Observer.observe(~S)>,debug:Bool) -> Build.Registered<S,W.World<S,P.Store<S>,F.Resources<S>,Unit>,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>:
  Build.Registered{world,owners,recipe,debug}
def make_schema_app(~S:Data,schema:Schema.Schema<S,P.Store<S>,F.Resources<S>>,registered:Build.Registered<S,W.World<S,P.Store<S>,F.Resources<S>,Unit>,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>) -> App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>:
  App.Application{schema,registered}
def make_schedule_app(~S:Data,app:App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>) -> Main.schedule_type(~S):
  Schedule.Application{app,plan,namespace,name,steps,needs}
def make_conditioned_app(~S:Data,app:Main.schedule_type(~S),bindings:Main.condition_bindings_type(~S)) -> Main.app_type(~S):
  Schedule.ConditionedApplication{app,bindings}
def recreate_app(~S:Data,schema:Schema.Schema<S,P.Store<S>,F.Resources<S>>,world:W.World<S,P.Store<S>,F.Resources<S>,Unit>,owners:Systems.Owners<S>,recipe:Tree.Recipe<W.World<S,P.Store<S>,F.Resources<S>,Unit>,String,Observer.observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,bindings:Main.condition_bindings_type(~S)) -> Main.app_type(~S):
  make_conditioned_app(~S,make_schedule_app(~S,make_schema_app(~S,schema,make_registered(~S,world,owners,recipe,debug)),plan,namespace,name,steps,needs),bindings)
def owner_views_pair(~S:Data,owners:Systems.Owners<S>,bindings:Main.condition_bindings_type(~S)) -> (Systems.Owners<S> & String) & (Main.condition_bindings_type(~S) & String):
  (Observer.owners(~S,owners),Observer.bindings(~S,bindings))
def owner_views_returned(~S:Data,schema:Schema.Schema<S,P.Store<S>,F.Resources<S>>,world:W.World<S,P.Store<S>,F.Resources<S>,Unit>,recipe:Tree.Recipe<W.World<S,P.Store<S>,F.Resources<S>,Unit>,String,Observer.observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,result:(Systems.Owners<S> & String) & (Main.condition_bindings_type(~S) & String)) -> Main.app_type(~S) & String:
  match result:
    case ((owners,ownersText),(bindings,guardsText)):app_snapshot(~S,recreate_app(~S,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs,bindings),ownersText,guardsText,status,observations,prior,label)
def owner_views(~S:Data,schema:Schema.Schema<S,P.Store<S>,F.Resources<S>>,world:W.World<S,P.Store<S>,F.Resources<S>,Unit>,owners:Systems.Owners<S>,recipe:Tree.Recipe<W.World<S,P.Store<S>,F.Resources<S>,Unit>,String,Observer.observe(~S)>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,bindings:Main.condition_bindings_type(~S)) -> Main.app_type(~S) & String:
  owner_views_returned(~S,schema,world,recipe,debug,plan,namespace,name,steps,needs,status,observations,prior,label,owner_views_pair(~S,owners,bindings))
def captured_registered(~S:Data,schema:Schema.Schema<S,P.Store<S>,F.Resources<S>>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,registered:Build.Registered<S,W.World<S,P.Store<S>,F.Resources<S>,Unit>,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>,bindings:Main.condition_bindings_type(~S)) -> Main.app_type(~S) & String:
  match registered:
    case Build.Registered{world,owners,recipe,debug}:owner_views(~S,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs,status,observations,prior,label,bindings)
def captured_schema(~S:Data,value:App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,status:String,observations:List<&2,Sch.Observation>,prior:String,label:String,bindings:Main.condition_bindings_type(~S)) -> Main.app_type(~S) & String:
  match value:
    case App.Application{schema,app}:captured_registered(~S,schema,plan,namespace,name,steps,needs,status,observations,prior,label,app,bindings)
def captured_schedule(~S:Data,value:Main.schedule_type(~S),bindings:Main.condition_bindings_type(~S),status:String,observations:List<&2,Sch.Observation>,prior:String,label:String) -> Main.app_type(~S) & String:
  match value:
    case Schedule.Application{app,plan,namespace,name,steps,needs}:captured_schema(~S,app,plan,namespace,name,steps,needs,status,observations,prior,label,bindings)
def captured_conditioned(~S:Data,value:Main.app_type(~S),status:String,observations:List<&2,Sch.Observation>,prior:String,label:String) -> Main.app_type(~S) & String:
  match value:
    case Schedule.ConditionedApplication{app,bindings}:captured_schedule(~S,app,bindings,status,observations,prior,label)
def captured(~S:Data,app:Main.app_type(~S),status:String,observations:List<&2,Sch.Observation>,prior:String,label:String) -> Main.app_type(~S) & String:
  captured_conditioned(~S,app,status,observations,prior,label)
def checkpoint(~S:Data,value:Run<S>,prior:String,label:String) -> Main.app_type(~S) & String:
  match value:
    case Run{app,observations,status}:captured(~S,app,status,observations,prior,label)

def append_flow(~S:Data,app:Main.app_type(~S),flow:P.Flow) -> Main.app_type(~S):
  Main.update_world(~S,app,world => Main.insert_flow(~S,world,flow))
def append_level(~S:Data,app:Main.app_type(~S),level:P.Level) -> Main.app_type(~S):
  Main.update_world(~S,app,world => Main.insert_level(~S,world,level))
def run2(~S:Data,prior:String,app:Main.app_type(~S)) -> Main.app_type(~S) & String:
  checkpoint(~S,run_result(~S,Main.run_once(~S,append_level(~S,append_flow(~S,app,P.Pause{}),P.High{}))),prior,"flow-pause-level-high")
def run3(~S:Data,prior:String,app:Main.app_type(~S)) -> Main.app_type(~S) & String:
  checkpoint(~S,run_result(~S,Main.run_once(~S,append_flow(~S,app,P.Play{}))),prior,"flow-play-repeat")
def finished_trace(~S:Data,pair:Main.app_type(~S) & String) -> String:
  match pair:
    case (_,text):text
def run3_final(~S:Data,prior:String,app:Main.app_type(~S)) -> String:
  finished_trace(~S,run3(~S,prior,app))
def run2_then3(~S:Data,pair:Main.app_type(~S) & String) -> String:
  match pair:
    case (app,prior):run3_final(~S,prior,app)
def run2_from_checkpoint(~S:Data,pair:Main.app_type(~S) & String) -> String:
  match pair:
    case (app,prior):run2_then3(~S,run2(~S,prior,app))
def run1(~S:Data,app:Main.app_type(~S)) -> String:
  run2_from_checkpoint(~S,checkpoint(~S,run_result(~S,Main.run_once(~S,app)),"","initial-run"))

def begin_initial(~S:Data,result:Maybe<&1,Main.app_type(~S)>) -> String:
  match result:
    case None{}:"setup-rejected\n"
    case Some{app}:run1(~S,app)
def begin(~S:Data,world:W.World<S,P.Store<S>,F.Resources<S>,Unit>) -> String:
  begin_initial(~S,Main.initial_app(~S,world))
def created(~S:Data,result:Maybe<&1,W.World<S,P.Store<S>,F.Resources<S>,Unit>>) -> String:
  match result:
    case None{}:"world-create-rejected\n"
    case Some{world}:begin(~S,world)
def trace(~S:Data) -> String:
  created(~S,Main.create(~S))
