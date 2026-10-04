import Base
import ../t11-replacement/spec.bend as S

# Language infrastructure only: introduction requires a LIVE guard and evidence.
def introduce(guard: Bool, -claim: Type, proof: claim) -> S.When(guard,claim):
  match guard:
    case False{}: Unit{}
    case True{}: proof

def live_conditional(guard: Bool) -> S.When(guard,{0n == 0n : Nat}):
  introduce(guard,{0n == 0n : Nat},{==})

# Non-definitional arithmetic equality needs structural computation.
def add_right_zero(+n: Nat) -> {Nat.add(n,0n) == n : Nat}:
  match n:
    case 0n: {==}
    case 1n+k:
      %add_right_zero(k) : {1n+Nat.add(k,0n) == 1n+_ : Nat}
      {==}

# Existing evidence may transport a Type mentioning an erased value.
def from_guard(-guard: Bool, e: {True{} == guard : Bool}) -> S.When(guard,{0n == 0n : Nat}):
  %e : S.When(_,{0n == 0n : Nat})
  {==}
