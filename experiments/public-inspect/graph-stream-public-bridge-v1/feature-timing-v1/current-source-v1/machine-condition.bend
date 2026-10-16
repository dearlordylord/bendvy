import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/check.bend as K
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../../src/ecs/ordinary-inspector-relation.bend as Decl
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/capabilities.bend as Cap
import ./state.bend as State
import ./category.bend as C
import ./category-run.bend as Cases
import ./guard.bend as Guard

def World(~S:Data) -> Type: C.World(~S)
def flow_decl(~S:Data) -> MD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>:
  MD.declared(~S,~State.FlowToken,~U32,~State.Resources<S>,~State.flow(~S),"Flow",[4,7,8,9])
def Caps(~S:Data,~H:Type) -> Type:
  Cap.Bundle<Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>,C.Query(~S,~H)>
def flow_cap(~S:Data,~H:Type,caps:Caps(~S,~H)) -> Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>:
  match caps:
    case Cap.Bundle{flow,_}:flow
def rows_cap(~S:Data,~H:Type,caps:Caps(~S,~H)) -> C.Query(~S,~H):
  match caps:
    case Cap.Bundle{_,rows}:rows
def flow_checked(~S:Data,~H:Type,~rows:C.Query(~S,~H),observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):C.condition_body(~S,~H,~rows,2n,owner)
def body(~S:Data,~H:Type,~caps:Caps(~S,~H),_:Unit,owner:H) -> H & Bool:
  flow_checked(~S,~H,~rows_cap(~S,~H,caps),MD.matches(~H,~S,~State.FlowToken,~U32,~U32.is_eq,~flow_cap(~S,~H,caps),owner,7))
def query_cap(~S:Data,plan:K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => C.Query(~S,~H)>) -> C.Query(~S,~K.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>):
  match plan:
    case K.Plan{_,caps}:caps
# Exactly REQUIRED Link, not the old optional-four-cell machine count query.
def plan(~S:Data) -> K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Caps(~S,~H)>:
  K.Plan{MD.required(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow_decl(~S)),Cap.Bundle{MD.condition(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow_decl(~S)),query_cap(~S,C.condition_plan(~S,~C.link_required_out(~S)))}}
def predicate(~S:Data,world:World(~S),_:U32) -> World(~S) & Result<K.Error,Bool>:
  Cases.predicate_done(~S,K.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~(H => Caps(~S,~H)),~Unit,~body(~S),~plan(~S),Unit{},world))
def run(~S:Data,physical:Bool,name:String,world:World(~S)) -> World(~S) & Guard.Value:
  Guard.run(~S,~predicate(~S),physical,name,world)
