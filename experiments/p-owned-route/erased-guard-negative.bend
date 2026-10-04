import Base
import ./language.bend as P
import ../t11-replacement/spec.bend as S

def attempt(-guard: Bool) -> S.When(guard,{0n == 0n : Nat}):
  P.introduce(guard,{0n == 0n : Nat},{==})
