import Base
import ../consumer.bend as Consumer
import ../state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
type Schema is Data:
  Schema{}
def descriptor() -> G.Descriptor<Schema>:
  G.Descriptor{7,"Link","LinkedBy",G.Ordinary{}}
def forbidden(frame:T.Tx<Consumer.World(~Schema),A.Notice<Schema,U32>>) -> T.Tx<Consumer.World(~Schema),A.Notice<Schema,U32>> & A.QueueStatus:
  P.relate(~T.Tx<Consumer.World(~Schema),A.Notice<Schema,U32>>,~Schema,~P.provide_read(~Schema,~State.Components<Schema>,~State.Resources<Schema>,~U32,~descriptor()),frame,P.Targets{W.Handle{1,1},W.Handle{1,2}})
def main() -> String:
  "source authority control"
