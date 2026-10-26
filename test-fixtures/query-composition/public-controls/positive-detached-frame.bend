import Base
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/entity-key.bend as Key

# Concrete detached owners remain constructible; they cannot replace abstract H.
def construct(world: W.World<Unit,Unit,Unit,U32>) -> Q.Frame<Unit,Unit,Unit,U32>:
  Q.Frame{T.begin(~W.World<Unit,Unit,Unit,U32>,~U32,world),W.Handle{1,Key.EntityKey{1,0}},None{},None{}}
def observed(frame: Q.Frame<Unit,Unit,Unit,U32>) -> U32:
  0
def empty(_: Unit) -> Unit: Unit{}
def created(result: W.Creation<Unit,Unit,Unit,U32>) -> U32:
  match result:
    case W.Created{_,world}: observed(construct(world))
    case W.CreateRejected{_,_}: 1
def main() -> U32:
  created(W.create(~Unit,~Unit,~Unit,~U32,~empty,W.factory(),Unit{}))
