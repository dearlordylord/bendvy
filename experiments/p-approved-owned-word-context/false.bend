import Base
import ./helpers.bend as H

def invalid_reserve_premise() -> {True{} == U32.is_lt(0,4294967295) : Bool}:
  H.reserve_below_max(0,0,{==})
