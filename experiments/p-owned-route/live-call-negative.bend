import Base
import ./language.bend as P

def attempt(-n: Nat) -> {Nat.add(n,0n) == n : Nat}:
  P.add_right_zero(n)
