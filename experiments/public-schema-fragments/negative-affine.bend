import Base
import ../../src/ecs/schema-fragments.bend as F
import fragment-left.bend as L

type Schema is Data:
  Schema{}
def duplicate(value: F.Fragment<Schema,L.Payload>) -> F.Fragment<Schema,L.Payload> & F.Fragment<Schema,L.Payload>:
  (value,value)
