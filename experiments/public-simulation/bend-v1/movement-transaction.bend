import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import ./storage.bend as Storage
import ./step.bend as Step

# Use the existing opaque-capability traversal with the same transaction journal.
# Do not finish the resource prefix separately: a later row failure must restore it.
def traversed(~S: Data,~Ops: Type -> Type,~A: Data,~Error: Data,~Out: Data,~plan: Q.Plan<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),args: A,observed: Step.World(~S) & List<&2,W.Handle<S>>) -> Q.Executed<Step.World(~S),Q.Error<Error>,Out>:
  match observed:
    case (world,handles):
      Q.finished(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Error,~Out,Q.run_handles(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Ops,~A,~Error,~Out,~plan,~body,handles,args,0,Step.begin(~S,world)))
def execute(~S: Data,~Ops: Type -> Type,~A: Data,~Error: Data,~Out: Data,~plan: Q.Plan<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),args: A,world: Step.World(~S)) -> Q.Executed<Step.World(~S),Q.Error<Error>,Out>:
  traversed(~S,~Ops,~A,~Error,~Out,~plan,~body,args,W.handles(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world))
