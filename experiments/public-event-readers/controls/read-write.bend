import Base
import ../../../src/ecs/event-runtime.bend as E

def bad(~H: Type,~observe: H -> H & E.Reading<U32>,~publish: H -> U32 -> H,ops: E.ReadAccess<H,U32,observe>,owner: H) -> H:
  E.emit(~H,~U32,~publish,ops,owner,1)
