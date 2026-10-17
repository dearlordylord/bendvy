import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/world.bend as W
def denied(state:Array<U32>,ignored:Trace.TraceEvent<String>) -> W.World<Unit,Unit,Unit,Unit>:state
