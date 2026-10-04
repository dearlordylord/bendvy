import Base
import ./language.bend as P
import ../t11-replacement/spec.bend as S

def false_fact() -> S.When(False{},{0n == 0n : Nat}):
  P.from_guard(False{},{==})
