import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
def denied(subscriber:Trace.Subscriber<Array<U32>,String,Positive.step>,incoming:Array<U32>) -> (Trace.Subscriber<Array<U32>,String,Positive.step> & Array<U32>) & Array<U32>:(Trace.reset(~Array<U32>,~String,~Positive.step,subscriber,incoming),incoming)
