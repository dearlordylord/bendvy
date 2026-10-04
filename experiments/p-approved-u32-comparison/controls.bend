import Base
import ../t11-replacement/bridge.bend as B

def true_instance() -> {B.less(0,1) == Nat.is_lt(U32.to_nat(0),U32.to_nat(1)) : Bool}:
  {==}
