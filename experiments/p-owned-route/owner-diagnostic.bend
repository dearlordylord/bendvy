import Base
import ./language.bend as P
import ../t11-replacement/spec.bend as S

type Owner is Type:
  Owner{flag: Bool}
def flag(owner: Owner) -> Bool:
  match owner:
    case Owner{b}: b

# Feasibility signature only: one live owner consumed; not an ECS law revision.
def live(owner: Owner) -> S.When(flag(owner),{0n == 0n : Nat}):
  match owner:
    case Owner{b}: P.introduce(b,{0n == 0n : Nat},{==})
