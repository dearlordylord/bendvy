import Base
import ../../../../../src/ecs/execution-trace.bend as Trace

def reset(~State:Type,~Error:Data,~step:State -> Trace.TraceEvent<Error> -> State,value:Trace.Subscriber<State,Error,step>,incoming:State) -> Trace.Subscriber<State,Error,step> & State:
  match value:
    case Trace.Subscriber{state}:(Trace.Subscriber{incoming},state)
def deliver(~State:Type,~Error:Data,~step:State -> Trace.TraceEvent<Error> -> State,value:Trace.Subscriber<State,Error,step>,batch:Trace.Batch<Error>) -> Trace.Subscriber<State,Error,step>:
  match value batch:
    case subscriber Trace.Disabled{}:subscriber
    case Trace.Subscriber{state} Trace.Ready{events}:Trace.Subscriber{Trace.delivered(~State,~Error,~step,events,state)}

# Generic owner composition has no arity or subscriber-count bound. Order is
# left then right; each reusable delivery function can itself be another pair.
