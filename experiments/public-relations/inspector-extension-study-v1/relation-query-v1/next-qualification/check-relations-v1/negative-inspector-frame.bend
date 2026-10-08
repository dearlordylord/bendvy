import Base
import adapter.bend as Bridge
import ../../core-v1/src/ecs/inspector.bend as I
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/relation-commands.bend as A
import ../../core-v1/src/ecs/relation-types.bend as G

def refused(~S:Data,~C:Type,~R:Type,~E:Data,frame:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>:
  Bridge.graph(~S,~C,~R,~E,frame)
def main() -> Nat:
  0n
