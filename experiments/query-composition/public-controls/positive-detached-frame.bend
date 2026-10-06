import Base
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

# Concrete detached owners remain constructible; they cannot replace abstract H.
def construct(world: W.World<Unit,Unit,Unit,U32>) -> Q.Frame<Unit,Unit,Unit,U32>:
  Q.Frame{T.begin(~W.World<Unit,Unit,Unit,U32>,~U32,world),W.Handle{1,1},None{},0}
def observed(frame: Q.Frame<Unit,Unit,Unit,U32>) -> U32:
  0
def main() -> U32:
  observed(construct(W.World{1,2,1,Array.new(Bool,1n,True{}),2,1n,Unit{},Unit{},[],[],[],1,0}))
