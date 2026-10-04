import Base
import ./owner-diagnostic.bend as D
import ../t11-replacement/spec.bend as S

def attempt(-owner: D.Owner) -> S.When(D.flag(owner),{0n == 0n : Nat}):
  D.live(owner)
