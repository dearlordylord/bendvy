import Base
import ./subscriber-positive.bend as Positive
import ../../../../src/ecs/execution-trace.bend as Trace
def denied(state:Array<U32>) -> Trace.Subscriber<Array<U32>,String,Positive.step> & Array<U32>:(Trace.subscribe(~Array<U32>,~String,~Positive.step,state),state)
