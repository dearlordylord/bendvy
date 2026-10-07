import Base
import batch.bend as BT
import ../../../../src/ecs/world.bend as W
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def bad(batch:BT.Batch<Schema,Array<U32>,Array<U32>,U32,Array<U32>>,target:W.Handle<Other>,payload:Array<U32>) -> BT.Inserted<Schema,Array<U32>,Array<U32>,U32,Array<U32>>:
  BT.insert(~Schema,~Array<U32>,~Array<U32>,~U32,~Array<U32>,batch,target,payload)
