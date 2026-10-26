import Base
import ../payloads.bend as P
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-command-local.bend as Local
type Schema is Data:
  Schema{}
def undeclared(~H:Type,~O:Type,caps:Query.OutputEach<Schema,H,O,String>) -> Local.Commands<O,Schema,P.Output>:caps
