import Base
import ./language.bend as P

def formation(-n: Nat) -> Type:
  -proof = P.add_right_zero(n)
  {proof == proof : {Nat.add(n,0n) == n : Nat}}
