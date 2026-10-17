import Base
import ../../../../src/ecs/execution-trace.bend as Trace
# Arbitrary affine state and top-level steps; reset returns both real owners.
def reset_returned(~State:Type,~Error:Data,~step:State -> Trace.TraceEvent<Error> -> State,batch:Trace.Batch<Error>,pair:Trace.Subscriber<State,Error,step> & State) -> State & State:
  match pair:
    case (subscriber,displaced):(Trace.unsubscribe(~State,~Error,~step,Trace.deliver(~State,~Error,~step,subscriber,batch)),displaced)
def roundtrip(~State:Type,~Error:Data,~step:State -> Trace.TraceEvent<Error> -> State,state:State,incoming:State,+batch:Trace.Batch<Error>) -> State & State:
  reset_returned(~State,~Error,~step,batch,Trace.reset(~State,~Error,~step,Trace.deliver(~State,~Error,~step,Trace.subscribe(~State,~Error,~step,state),batch),incoming))
def paired(~A:Type,~B:Type,~Error:Data,~a:A -> Trace.Batch<Error> -> A,~b:B -> Trace.Batch<Error> -> B,value:A & B,batch:Trace.Batch<Error>) -> A & B:Trace.both(~A,~B,~Error,~a,~b,value,batch)
def composed(~A:Type,~B:Type,~C:Type,~Error:Data,~a:A -> Trace.Batch<Error> -> A,~b:B -> Trace.Batch<Error> -> B,~c:C -> Trace.Batch<Error> -> C,value:(A & B) & C,batch:Trace.Batch<Error>) -> (A & B) & C:
  Trace.both(~(A & B),~C,~Error,~paired(~A,~B,~Error,~a,~b),~c,value,batch)
def step(owner:Array<U32>,ignored:Trace.TraceEvent<String>) -> Array<U32>:owner
