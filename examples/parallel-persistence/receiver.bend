import Base
import ./declarations.bend as Ordinary
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-restore-clear.bend as Clear
import ../../src/ecs/change-tick.bend as Tick
def Components(~S:Data) -> Layout.Layout:Plan.layout(Ordinary.components(~S))
def Resources(~S:Data) -> Type:Layout.resources(~S,Plan.layout(Ordinary.resources(~S)))
def World(~S:Data) -> Type:W.World<S,Layout.columns(~S,Components(~S)),Resources(~S),Unit>
def prepare(~S:Data,needed:Nat,world:World(~S)) -> Receiver.Prepared<S,Components(~S),Resources(~S),Unit>:
  Receiver.prepare(~S,~Components(~S),~Resources(~S),~Unit,needed,world)
def alpha(needed:Nat,world:World(~Ordinary.Alpha)) -> Receiver.Prepared<Ordinary.Alpha,Components(~Ordinary.Alpha),Resources(~Ordinary.Alpha),Unit>:prepare(~Ordinary.Alpha,needed,world)
def beta(needed:Nat,world:World(~Ordinary.Beta)) -> Receiver.Prepared<Ordinary.Beta,Components(~Ordinary.Beta),Resources(~Ordinary.Beta),Unit>:prepare(~Ordinary.Beta,needed,world)
def clear(~S:Data,handles:List<&2,W.Handle<S>>,world:World(~S),tick:Tick.Tick) -> Clear.Cleared<S,Components(~S),Layout.InLeft{Layout.AtLeaf{}},Resources(~S),Unit>:
  Clear.clear(~S,~Components(~S),~Layout.InLeft{Layout.AtLeaf{}},~Resources(~S),~Unit,handles,world,tick)
def clear_alpha(handles:List<&2,W.Handle<Ordinary.Alpha>>,world:World(~Ordinary.Alpha),tick:Tick.Tick) -> Clear.Cleared<Ordinary.Alpha,Components(~Ordinary.Alpha),Layout.InLeft{Layout.AtLeaf{}},Resources(~Ordinary.Alpha),Unit>:clear(~Ordinary.Alpha,handles,world,tick)
def clear_beta(handles:List<&2,W.Handle<Ordinary.Beta>>,world:World(~Ordinary.Beta),tick:Tick.Tick) -> Clear.Cleared<Ordinary.Beta,Components(~Ordinary.Beta),Layout.InLeft{Layout.AtLeaf{}},Resources(~Ordinary.Beta),Unit>:clear(~Ordinary.Beta,handles,world,tick)
