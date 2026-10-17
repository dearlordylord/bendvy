import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
def denied(state:Array<U32>,ignored:Trace.TraceEvent<String>) -> Array<U32>:IO.pure(Array<U32>,state)
