import Base

@unsafe
def promised(+value: Nat) -> Nat:
  value

def rely(+value: Nat) -> Nat:
  promised(value)
