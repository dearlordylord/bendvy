import Base

type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def affine(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def duplicated(+value:U32) -> U32 & U32:(value,value)
def reusable(value:U32) -> U32 & U32:duplicated(value)
