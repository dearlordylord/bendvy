import Base
import ./positive.bend as P
import ../../../src/ecs/execution-command-local.bend as L
import ../../../src/ecs/world.bend as W

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def bad(~Q:Type,commands:L.Commands<Q,SchemaA,P.Token>,queue:Q,handle:W.Handle<SchemaB>,payload:P.Token) -> Q:
  L.insert_field(~Q,~SchemaA,~P.Token,commands)(queue,handle,payload)
