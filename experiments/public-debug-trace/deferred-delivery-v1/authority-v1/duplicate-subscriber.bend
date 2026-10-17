import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
def denied(subscriber:Trace.Subscriber<Array<U32>,String,Positive.step>) -> Trace.Subscriber<Array<U32>,String,Positive.step> & Trace.Subscriber<Array<U32>,String,Positive.step>:(subscriber,subscriber)
