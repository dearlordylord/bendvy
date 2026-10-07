import Base
import ../adapter.bend as AD
import ../../../../src/ecs/world.bend as W
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def bad(input:AD.Input<Other,Array<U32>>) -> AD.Input<Schema,Array<U32>>:
  input
