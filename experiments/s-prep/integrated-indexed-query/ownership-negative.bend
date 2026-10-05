import Base
import ./query.bend as Q
def duplicate(state: Q.StructIdxState<U32,U32,U32,U32>) -> Q.StructIdxState<U32,U32,U32,U32> & Q.StructIdxState<U32,U32,U32,U32>:
  (state,state)
