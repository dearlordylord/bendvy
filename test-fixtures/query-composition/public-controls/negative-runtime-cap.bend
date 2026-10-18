import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp

type Owner is Type:
  Owner{values: Array<U32>}
def projected(value: Array<U32> & U32) -> Owner & Cmp.Access<U32>:
  (values,value) = value
  (Owner{values},Cmp.Found{value})
def getter(owner: Owner) -> Owner & Cmp.Access<U32>:
  match owner:
    case Owner{values}: projected(Array.get(U32,values,0))

# A runtime affine operation record cannot enter the closed-template seam.
def bad(~H: Type,cap: Cap.Read<H,U32>,ctx: H) -> H & Cmp.Access<U32>:
  Cap.read(~H,~U32,~cap,ctx)

def main() -> Owner & Cmp.Access<U32>:
  bad(~Owner,Cap.Read{getter},Owner{[7 : U32^0n]})
