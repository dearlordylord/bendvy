import Base
import ../basic-world-statefree-v1/schema.bend as F
import ../../../src/ecs/capabilities.bend as C
def owner(~S:Data,value:F.Owned(~S)) -> F.Owned(~S):value
def read(~H:Type,value:C.Read<H,U32>) -> C.Read<H,U32>:value
def write(~H:Type,value:C.Write<H,Array<U32>,U32>) -> C.Write<H,Array<U32>,U32>:value
