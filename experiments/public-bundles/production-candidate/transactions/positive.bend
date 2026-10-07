import Base
import batch.bend as BT
import ../../../public-bundles/prototype.bend as B
type Schema is Data:
  Schema{}
def identity(batch:BT.Batch<Schema,Array<U32>,Array<U32>,U32,B.Pack<Array<U32>,B.Pack<Array<U32>,Unit>>>) -> BT.Batch<Schema,Array<U32>,Array<U32>,U32,B.Pack<Array<U32>,B.Pack<Array<U32>,Unit>>>:
  batch
