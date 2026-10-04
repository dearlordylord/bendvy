import Base
import ./infrastructure.bend as P

def attempt(-guard: Bool) -> P.GuardWitness(guard):
  (guard,{==})
