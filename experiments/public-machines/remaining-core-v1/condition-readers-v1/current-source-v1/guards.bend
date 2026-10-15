import Base
import ../provider.bend as P
import fixture.bend as F
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../../src/ecs/ordinary-condition-composition.bend as Comp

def world_type(~S:Data) -> Type:W.World<S,P.Store<S>,F.Resources<S>,Unit>
def flow_changed_type(~S:Data) -> Type:Changed.Instance<S,P.FlowToken,P.Flow,P.Store<S>,F.Resources<S>,Unit,F.take_flow(~S),F.put_flow(~S)>
def level_changed_type(~S:Data) -> Type:Changed.Instance<S,P.LevelToken,P.Level,P.Store<S>,F.Resources<S>,Unit,F.take_level(~S),F.put_level(~S)>
def flow_current_declaration(~S:Data) -> OD.Declaration<S,P.FlowToken,P.Flow,F.Resources<S>,F.flow_take(~S)>:OD.Declaration{"Flow"}
def level_current_declaration(~S:Data) -> OD.Declaration<S,P.LevelToken,P.Level,F.Resources<S>,F.level_take(~S)>:OD.Declaration{"Level"}

def fast_left_run(~S:Data) -> P.Flow -> world_type(~S) -> Comp.Evaluation<world_type(~S),P.Flow>:
  Comp.current_run(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.flow_take(~S),~P.Store<S>,~Unit,~P.flow_same)
def fast_right_run(~S:Data) -> level_changed_type(~S) -> world_type(~S) -> Comp.Evaluation<world_type(~S),level_changed_type(~S)>:
  Comp.changed_run(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.take_level(~S),~F.put_level(~S),~P.Store<S>,~Unit)
def fast_run(~S:Data) -> (P.Flow & level_changed_type(~S)) -> world_type(~S) -> Comp.Evaluation<world_type(~S),P.Flow & level_changed_type(~S)>:
  Comp.and_run(~world_type(~S),~P.Flow,~level_changed_type(~S),~fast_left_run(~S),~fast_right_run(~S))
def fast_condition_type(~S:Data) -> Type:
  Comp.Condition<world_type(~S),P.Flow & level_changed_type(~S),fast_run(~S)>
def fast_condition(~S:Data,instance:level_changed_type(~S)) -> fast_condition_type(~S):
  Comp.and_then(~world_type(~S),~P.Flow,~level_changed_type(~S),~fast_left_run(~S),~fast_right_run(~S),Comp.in_state(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.flow_take(~S),~P.Store<S>,~Unit,~P.flow_same,~flow_current_declaration(~S),P.Play{}),Comp.state_changed(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.take_level(~S),~F.put_level(~S),~P.Store<S>,~Unit,instance))
def fast_bound_type(~S:Data) -> Type:Comp.BoundOwner<(P.Flow & level_changed_type(~S))>
def fast_bindings_type(~S:Data) -> Type:Comp.Bindings<world_type(~S),fast_bound_type(~S),Comp.bound_run(~world_type(~S),~(P.Flow & level_changed_type(~S)),~fast_run(~S))>
def fast_bind(~S:Data,id:U32,instance:level_changed_type(~S)) -> fast_bindings_type(~S):
  Comp.bind(~world_type(~S),~(P.Flow & level_changed_type(~S)),~fast_run(~S),id,fast_condition(~S,instance))

def slow_left_run(~S:Data) -> P.Level -> world_type(~S) -> Comp.Evaluation<world_type(~S),P.Level>:
  Comp.not_run(~world_type(~S),~P.Level,~Comp.current_run(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.level_take(~S),~P.Store<S>,~Unit,~P.level_same))
def slow_right_run(~S:Data) -> flow_changed_type(~S) -> world_type(~S) -> Comp.Evaluation<world_type(~S),flow_changed_type(~S)>:
  Comp.changed_run(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.take_flow(~S),~F.put_flow(~S),~P.Store<S>,~Unit)
def slow_run(~S:Data) -> (P.Level & flow_changed_type(~S)) -> world_type(~S) -> Comp.Evaluation<world_type(~S),P.Level & flow_changed_type(~S)>:
  Comp.or_run(~world_type(~S),~P.Level,~flow_changed_type(~S),~slow_left_run(~S),~slow_right_run(~S))
def slow_condition_type(~S:Data) -> Type:
  Comp.Condition<world_type(~S),P.Level & flow_changed_type(~S),slow_run(~S)>
def slow_condition(~S:Data,instance:flow_changed_type(~S)) -> slow_condition_type(~S):
  Comp.or_else(~world_type(~S),~P.Level,~flow_changed_type(~S),~slow_left_run(~S),~slow_right_run(~S),Comp.not(~world_type(~S),~P.Level,~Comp.current_run(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.level_take(~S),~P.Store<S>,~Unit,~P.level_same),Comp.in_state(~S,~P.LevelToken,~P.Level,~F.Resources<S>,~F.level_take(~S),~P.Store<S>,~Unit,~P.level_same,~level_current_declaration(~S),P.High{})),Comp.state_changed(~S,~P.FlowToken,~P.Flow,~F.Resources<S>,~F.take_flow(~S),~F.put_flow(~S),~P.Store<S>,~Unit,instance))
def slow_bound_type(~S:Data) -> Type:Comp.BoundOwner<(P.Level & flow_changed_type(~S))>
def slow_bindings_type(~S:Data) -> Type:Comp.Bindings<world_type(~S),slow_bound_type(~S),Comp.bound_run(~world_type(~S),~(P.Level & flow_changed_type(~S)),~slow_run(~S))>
def slow_bind(~S:Data,id:U32,instance:flow_changed_type(~S)) -> slow_bindings_type(~S):
  Comp.bind(~world_type(~S),~(P.Level & flow_changed_type(~S)),~slow_run(~S),id,slow_condition(~S,instance))

def bindings_type(~S:Data) -> Type:
  Comp.Bindings<world_type(~S),fast_bound_type(~S) & slow_bound_type(~S),Comp.sequence_run(~world_type(~S),~fast_bound_type(~S),~slow_bound_type(~S),~Comp.bound_run(~world_type(~S),~(P.Flow & level_changed_type(~S)),~fast_run(~S)),~Comp.bound_run(~world_type(~S),~(P.Level & flow_changed_type(~S)),~slow_run(~S)))>
def bindings(~S:Data,fastId:U32,slowId:U32,fast:level_changed_type(~S),slow:flow_changed_type(~S)) -> bindings_type(~S):
  Comp.sequence(~world_type(~S),~fast_bound_type(~S),~slow_bound_type(~S),~Comp.bound_run(~world_type(~S),~(P.Flow & level_changed_type(~S)),~fast_run(~S)),~Comp.bound_run(~world_type(~S),~(P.Level & flow_changed_type(~S)),~slow_run(~S)),fast_bind(~S,fastId,fast),slow_bind(~S,slowId,slow))
