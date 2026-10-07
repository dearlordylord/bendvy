import Base
import ../../../src/ecs/event-runtime.bend as E

def bad(~H: Type,ops: Unit,owner: H) -> H & E.Reading<U32>:
  E.all(~H,~U32,~(h => (h,E.Reading{[],False{}})),ops,owner)
