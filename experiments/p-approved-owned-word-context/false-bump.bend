import Base
import ./helpers.bend as H

def invalid_bump_result() -> {U32.to_nat(U32.add(7,1)) == 9n : Nat}:
  H.bump_increment(7,{==})
