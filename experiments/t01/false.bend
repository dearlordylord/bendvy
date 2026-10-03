import Base

# Planted false claim: identical attempted proof, changed RHS.
def canary() -> {Nat.add(2n, 0n) == 3n : Nat}:
  {==}
