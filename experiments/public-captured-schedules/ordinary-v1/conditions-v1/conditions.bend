import Base
import ./state.bend as St
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../src/ecs/ordinary-condition-composition.bend as Cond
import ../../../../src/ecs/system.bend as Sys
def Instance(~S:Data) -> Type:
  Changed.Instance<S,St.Mode,U32,Col.Column<S,U32>,St.Resources<S>,Unit,St.take(~S),St.put(~S)>
def Owners(~S:Data) -> Type:
  Cond.BoundOwner<Instance(~S)> & Cond.BoundOwner<Bool>
def select(~S:Data,owners:Owners(~S),world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,id:U32) -> Cond.Evaluation<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Owners(~S)>:
  Cond.sequence_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Cond.BoundOwner<Instance(~S)>,~Cond.BoundOwner<Bool>,~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Instance(~S),~Cond.changed_run(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit)),~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Bool,~Cond.constant_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>)))(owners,world,id)
def Bindings(~S:Data) -> Type:
  Cond.Bindings<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Owners(~S),select(~S)>
def rebound(~S:Data,value:Cond.Bindings<W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,Owners(~S),Cond.sequence_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Cond.BoundOwner<Instance(~S)>,~Cond.BoundOwner<Bool>,~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Instance(~S),~Cond.changed_run(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit)),~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Bool,~Cond.constant_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>)))>) -> Bindings(~S):
  match value:
    case Cond.Bindings{owners,descriptions}:Cond.Bindings{owners,descriptions}
def bind(~S:Data,instance:Instance(~S)) -> Bindings(~S):
  rebound(~S,Cond.sequence(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Cond.BoundOwner<Instance(~S)>,~Cond.BoundOwner<Bool>,~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Instance(~S),~Cond.changed_run(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit)),~Cond.bound_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Bool,~Cond.constant_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>)),Cond.bind(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Instance(~S),~Cond.changed_run(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit),1,Cond.state_changed(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit,instance)),Cond.bind(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,~Bool,~Cond.constant_run(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>),2,Cond.constant(~W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>,True{}))))
def define(~S:Data,world:W.World<S,Col.Column<S,U32>,St.Resources<S>,Unit>) -> Changed.Definition<S,St.Mode,U32,Col.Column<S,U32>,St.Resources<S>,Unit,St.take(~S),St.put(~S)>:
  Changed.define(~S,~St.Mode,~U32,~St.Resources<S>,~St.take(~S),~St.put(~S),~Col.Column<S,U32>,~Unit,~St.declaration(~S),world,"mode-changed")
def text(value:String) -> String:value
def leaf(value:Cond.LeafDescription) -> String:
  match value:
    case Cond.StateChanged{ns,id,name,access}:"changed:" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access)
    case Cond.InState{name}:"in-state:" ++ name
    case Cond.Constant{value}:"constant:" ++ Bool.show(value)
def description(value:Cond.BindingDescription) -> String:
  match value:
    case Cond.BindingDescription{id,Cond.Description{name,access,leaves}}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":" ++ List.show(~&2,~Cond.LeafDescription,~leaf,leaves)
def observed(~S:Data,value:Bindings(~S)) -> Bindings(~S) & String:
  match value:
    case Cond.Bindings{(Cond.BoundOwner{+a,Changed.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},+revision}},Cond.BoundOwner{+b,+enabled}),+descriptions}:
      (Cond.Bindings{(Cond.BoundOwner{a,Changed.Instance{Sys.Registry{ns,id,name,access,cursor},revision}},Cond.BoundOwner{b,enabled}),descriptions},U32.show(a) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":revision=" ++ Nat.show(revision) ++ ";" ++ U32.show(b) ++ ":" ++ Bool.show(enabled) ++ ":descriptions=" ++ List.show(~&2,~Cond.BindingDescription,~description,descriptions))
