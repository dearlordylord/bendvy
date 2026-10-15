import Base
import ../provider.bend as P
import fixture.bend as F
import guards.bend as G
import systems.bend as Systems
import observer.bend as Observer
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../../src/ecs/ordinary-condition-composition.bend as Comp
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../../src/ecs/ordinary-app-schedule-description.bend as Named
import ../../../../../src/ecs/schedule.bend as Sch
import ../../../../../src/ecs/schedule-provision.bend as SP

def world_type(~S:Data) -> Type:W.World<S,P.Store<S>,F.Resources<S>,Unit>
def condition_owner_type(~S:Data) -> Type:G.fast_bound_type(~S) & G.slow_bound_type(~S)
def condition_eval(~S:Data) -> condition_owner_type(~S) -> world_type(~S) -> U32 -> Comp.Evaluation<world_type(~S),condition_owner_type(~S)>:
  Comp.sequence_run(~world_type(~S),~G.fast_bound_type(~S),~G.slow_bound_type(~S),~Comp.bound_run(~world_type(~S),~(P.Flow & G.level_changed_type(~S)),~G.fast_run(~S)),~Comp.bound_run(~world_type(~S),~(P.Level & G.flow_changed_type(~S)),~G.slow_run(~S)))
def app_type(~S:Data) -> Type:
  Schedule.ConditionedApplication<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S),condition_owner_type(~S),condition_eval(~S)>
def schedule_type(~S:Data) -> Type:Schedule.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>
def condition_bindings_type(~S:Data) -> Type:G.bindings_type(~S)
def condition_plan(~S:Data,fastId:U32,slowId:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.System{fastId,0},[]},SP.Entry{Sch.System{slowId,0},[]}}
def provision(~S:Data,world:world_type(~S)) -> world_type(~S) & List<&2,SP.Requirement<S>>:(world,[])

def select(~S:Data,owner:condition_owner_type(~S),world:world_type(~S),id:U32) -> Comp.Evaluation<world_type(~S),condition_owner_type(~S)>:
  condition_eval(~S,owner,world,id)

def attached_conditions(~S:Data,result:Schedule.ConditionAttachment<schedule_type(~S),condition_bindings_type(~S),app_type(~S)>) -> Maybe<&1,app_type(~S)>:
  match result:
    case Schedule.ConditionsAttached{app}:Some{app}
    case Schedule.ConditionsInvalid{_,_}:None{}
def scheduled_result(~S:Data,bindings:condition_bindings_type(~S),result:Schedule.Attachment<App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>,schedule_type(~S)>) -> Maybe<&1,app_type(~S)>:
  match result:
    case Schedule.Attached{app}:attached_conditions(~S,Schedule.attach_conditions(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Systems.Owners<S>,~String,~Observer.observe(~S),~Observer.fold(~S),~condition_owner_type(~S),~condition_eval(~S),app,bindings))
    case Schedule.Invalid{_}:None{}
def scheduled_app(~S:Data,fastId:U32,slowId:U32,app:App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>,bindings:condition_bindings_type(~S)) -> Maybe<&1,app_type(~S)>:
  scheduled_result(~S,bindings,Schedule.attach(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Systems.Owners<S>,~String,~Observer.observe(~S),~Observer.fold(~S),app,"ordinary-machine-condition-readers",condition_plan(~S,fastId,slowId)))

def update_world(~S:Data,app:app_type(~S),effect:world_type(~S) -> world_type(~S)) -> app_type(~S):
  match app:
    case Schedule.ConditionedApplication{Schedule.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}:
      Schedule.ConditionedApplication{Schedule.Application{App.Application{schema,Build.Registered{effect(world),owners,recipe,debug}},plan,namespace,name,steps,needs},bindings}

def insert_flow(~S:Data,world:world_type(~S),value:P.Flow) -> world_type(~S):
  Init.insert_state(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.take_flow(~S),~F.put_flow(~S),~P.Store<S>,~Unit,~F.flow_decl(~S),world,value)
def insert_level(~S:Data,world:world_type(~S),value:P.Level) -> world_type(~S):
  Init.insert_state(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.take_level(~S),~F.put_level(~S),~P.Store<S>,~Unit,~F.level_decl(~S),world,value)

def run_result_type(~S:Data) -> Type:Schedule.RunResult<app_type(~S),S,Comp.Error<String>>
def run_once(~S:Data,app:app_type(~S)) -> run_result_type(~S):
  Schedule.run_conditions(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Systems.Owners<S>,~String,~Observer.observe(~S),~Observer.fold(~S),~condition_owner_type(~S),~condition_eval(~S),~String,~Systems.dispatch(~S),~provision(~S),app)

def created(~S:Data,result:W.Creation<S,P.Store<S>,F.Resources<S>,Unit>) -> Maybe<&1,world_type(~S)>:
  match result:
    case W.Created{_,world}:Some{F.init_level(~S,F.init_flow(~S,world))}
    case _:None{}
def create(~S:Data) -> Maybe<&1,world_type(~S)>:
  created(~S,W.create(~S,~P.Store<S>,~F.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),W.factory(),F.empty_resources(~S)))

def level_instance_type(~S:Data) -> Type:Changed.Instance<S,P.LevelToken,P.Level,P.Store<S>,F.Resources<S>,Unit,F.take_level(~S),F.put_level(~S)>
def flow_instance_type(~S:Data) -> Type:Changed.Instance<S,P.FlowToken,P.Flow,P.Store<S>,F.Resources<S>,Unit,F.take_flow(~S),F.put_flow(~S)>
type Start<S:Data> is Type:
  StartReady{world:world_type(S),owners:Systems.Owners<S>,fastId:U32,slowId:U32,level:level_instance_type(S),flow:flow_instance_type(S)}

def flow_definition(~S:Data,owners:Systems.Owners<S>,fastId:U32,slowId:U32,level:level_instance_type(~S),result:Changed.Definition<S,P.FlowToken,P.Flow,P.Store<S>,F.Resources<S>,Unit,F.take_flow(~S),F.put_flow(~S)>) -> Maybe<&1,Start<S>>:
  match result:
    case Changed.Defined{world,instance}:Some{StartReady{world,owners,fastId,slowId,level,instance}}
    case Changed.DefinitionRejected{_}:None{}
def level_definition(~S:Data,owners:Systems.Owners<S>,fastId:U32,slowId:U32,result:Changed.Definition<S,P.LevelToken,P.Level,P.Store<S>,F.Resources<S>,Unit,F.take_level(~S),F.put_level(~S)>) -> Maybe<&1,Start<S>>:
  match result:
    case Changed.Defined{world,instance}:flow_definition(~S,owners,fastId,slowId,instance,Changed.define(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.take_flow(~S),~F.put_flow(~S),~P.Store<S>,~Unit,~F.flow_decl(~S),world,"condition-flow-changed"))
    case Changed.DefinitionRejected{_}:None{}
def define_level(~S:Data,world:world_type(~S),owners:Systems.Owners<S>,fastId:U32,slowId:U32) -> Maybe<&1,Start<S>>:
  level_definition(~S,owners,fastId,slowId,Changed.define(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.take_level(~S),~F.put_level(~S),~P.Store<S>,~Unit,~F.level_decl(~S),world,"condition-level-changed"))
def systems_identified(~S:Data,world:world_type(~S),result:Systems.Owners<S> & (U32 & U32)) -> Maybe<&1,Start<S>>:
  match result:
    case (owners,(fastId,slowId)):define_level(~S,world,owners,fastId,slowId)
def systems_registered(~S:Data,result:Systems.Registration<S>) -> Maybe<&1,Start<S>>:
  match result:
    case Systems.Ready{Systems.Registered{world,owners}}:
      systems_identified(~S,world,Systems.ids(~S,owners))
    case Systems.Refused{_}:None{}
    case Systems.Partial{_,_}:None{}
def start(~S:Data,world:world_type(~S)) -> Maybe<&1,Start<S>>:
  systems_registered(~S,Systems.register(~S,world))

def plain_app(~S:Data,world:world_type(~S),owners:Systems.Owners<S>) -> App.Application<S,P.Store<S>,F.Resources<S>,Unit,Systems.Owners<S>,String,Observer.observe(~S),Observer.fold(~S)>:
  App.attached(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Systems.Owners<S>,~String,~Observer.observe(~S),~Observer.fold(~S),Schema.Schema{[]},Build.Registered{world,owners,Tree.Recipe{},True{}})
def assembled(~S:Data,start:Start<S>) -> Maybe<&1,app_type(~S)>:
  match start:
    case StartReady{world,owners,+fastId,+slowId,level,flow}:
      scheduled_app(~S,fastId,slowId,plain_app(~S,world,owners),G.bindings(~S,fastId,slowId,level,flow))
def starting(~S:Data,result:Maybe<&1,Start<S>>) -> Maybe<&1,app_type(~S)>:
  match result:
    case None{}:None{}
    case Some{value}:assembled(~S,value)

def initial_app(~S:Data,world:world_type(~S)) -> Maybe<&1,app_type(~S)>:
  starting(~S,start(~S,world))
