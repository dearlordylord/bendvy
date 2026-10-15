import Base
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../../src/ecs/world.bend as W
import ../provider.bend as P

type Resources<S:Data> is Type:
  Resources{flow:Init.State<S,P.FlowToken,P.Flow>,level:Init.State<S,P.LevelToken,P.Level>}

def take_flow(~S:Data,resource:Resources<S>) -> Resources<S> & Init.State<S,P.FlowToken,P.Flow>:
  match resource:
    case Resources{+flow,level}:(Resources{flow,level},flow)
def put_flow(~S:Data,resource:Resources<S>,state:Init.State<S,P.FlowToken,P.Flow>) -> Resources<S>:
  match resource:
    case Resources{_,level}:Resources{state,level}
def take_level(~S:Data,resource:Resources<S>) -> Resources<S> & Init.State<S,P.LevelToken,P.Level>:
  match resource:
    case Resources{flow,+level}:(Resources{flow,level},level)
def put_level(~S:Data,resource:Resources<S>,state:Init.State<S,P.LevelToken,P.Level>) -> Resources<S>:
  match resource:
    case Resources{flow,_}:Resources{flow,state}

def flow_take(~S:Data,resource:Resources<S>) -> Resources<S> & M.Slot<S,P.FlowToken,P.Flow>:
  Init.take_slot(~S,~P.FlowToken,~P.Flow,~Resources<S>,~take_flow(~S),~put_flow(~S),resource)
def flow_put(~S:Data,resource:Resources<S>,slot:M.Slot<S,P.FlowToken,P.Flow>) -> Resources<S>:
  Init.put_slot(~S,~P.FlowToken,~P.Flow,~Resources<S>,~take_flow(~S),~put_flow(~S),~P.flow_same,resource,slot)
def level_take(~S:Data,resource:Resources<S>) -> Resources<S> & M.Slot<S,P.LevelToken,P.Level>:
  Init.take_slot(~S,~P.LevelToken,~P.Level,~Resources<S>,~take_level(~S),~put_level(~S),resource)
def level_put(~S:Data,resource:Resources<S>,slot:M.Slot<S,P.LevelToken,P.Level>) -> Resources<S>:
  Init.put_slot(~S,~P.LevelToken,~P.Level,~Resources<S>,~take_level(~S),~put_level(~S),~P.level_same,resource,slot)

def flow_decl(~S:Data) -> OD.Declaration<S,P.FlowToken,P.Flow,Resources<S>,Init.take_slot(~S,~P.FlowToken,~P.Flow,~Resources<S>,~take_flow(~S),~put_flow(~S))>:
  Init.declared(~S,~P.FlowToken,~P.Flow,~Resources<S>,~take_flow(~S),~put_flow(~S),"Flow",[P.Boot{},P.Play{},P.Pause{}])
def level_decl(~S:Data) -> OD.Declaration<S,P.LevelToken,P.Level,Resources<S>,Init.take_slot(~S,~P.LevelToken,~P.Level,~Resources<S>,~take_level(~S),~put_level(~S))>:
  Init.declared(~S,~P.LevelToken,~P.Level,~Resources<S>,~take_level(~S),~put_level(~S),"Level",[P.Low{},P.Middle{},P.High{}])

def empty_resources(~S:Data) -> Resources<S>:
  Resources{Init.empty(~S,~P.FlowToken,~P.Flow),Init.empty(~S,~P.LevelToken,~P.Level)}
def init_flow(~S:Data,world:W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  Init.init_state(~S,~P.FlowToken,~P.Flow,~Resources<S>,~take_flow(~S),~put_flow(~S),~P.Store<S>,~Unit,~flow_decl(~S),~(world => (world,P.Play{})),world)
def init_level(~S:Data,world:W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  Init.init_state(~S,~P.LevelToken,~P.Level,~Resources<S>,~take_level(~S),~put_level(~S),~P.Store<S>,~Unit,~level_decl(~S),~(world => (world,P.Low{})),world)
