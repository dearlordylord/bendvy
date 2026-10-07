import Base
import runtime-context.bend as X
import runtime-context-other.bend as Y
import runtime-core.bend as Core
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
def bad(world:W.World<Y.Schema,Y.Declarations,Y.Trace,U32>) -> Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  Core.runner(world,Unit{})
