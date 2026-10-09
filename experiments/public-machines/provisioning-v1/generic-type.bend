import Base
import initial.bend as I
import ../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../bendvy/src/ecs/machine.bend as M

type Schema is Data:
  Schema{}
type Machine is Data:
  Machine{}
type State is Data:
  State{}
def apply(~C: Type,~R: Type,
  ~take: W.World<Schema,C,R,Unit> -> W.World<Schema,C,R,Unit> & M.Slot<Schema,Machine,State>,
  ~put: W.World<Schema,C,R,Unit> -> M.Slot<Schema,Machine,State> -> W.World<Schema,C,R,Unit>,
  family: M.Family<Schema,Machine,State,W.World<Schema,C,R,Unit>,take,put>,world: W.World<Schema,C,R,Unit>) -> I.Installation<W.World<Schema,C,R,Unit>,State>:
  I.install_empty(~Schema,~Machine,~State,~W.World<Schema,C,R,Unit>,~take,~put,family,world,State{})
def main() -> Unit:
  Unit{}
