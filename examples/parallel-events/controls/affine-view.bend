import Base
import ../../../src/ecs/execution-access.bend as Access

def read(~H:Type,cap:Access.ResourceRead<H,Array<U32>>) -> Access.ResourceRead<H,Array<U32>>:cap
