import Base
import ../t11-replacement/spec.bend as S
import ../t11-replacement/bridge.bend as B

# UNAPPROVED supporting arithmetic candidates, selected unchanged.
law u32_increment_no_wrap:
  for +value: U32
  S.When(U32.is_lt(value,4294967295), {U32.to_nat(B.increment(value)) == 1n+U32.to_nat(value) : Nat})

law u32_comparison_agrees_nat:
  for +left: U32
  for +right: U32
  {B.less(left, right) == Nat.is_lt(U32.to_nat(left), U32.to_nat(right)) : Bool}
