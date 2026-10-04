import Base
import ../t11-replacement/bridge.bend as B

law u32_comparison_agrees_nat:
  for +left: U32
  for +right: U32
  {B.less(left, right) == Nat.is_lt(U32.to_nat(left), U32.to_nat(right)) : Bool}
