import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
type Schema is Data:
  Schema{}
def body(~H:Type,~caps:P.ReadOnly<H,Schema>,owner:H,targets:P.Targets<Schema>) -> H & A.QueueStatus:
  P.relate(~H,~Schema,~caps,owner,targets)
def main() -> Unit:
  Unit{}
