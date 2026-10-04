import Base
import ../t11-replacement/spec.bend as S

def introduce(guard: Bool) -> S.When(guard,{0n == 0n : Nat}):
  match guard:
    case False{}: Unit{}
    case True{}: {==}

def specialized(~guard: Bool) -> S.When(guard,{0n == 0n : Nat}):
  introduce(guard)

def true_specialization() -> S.When(True{},{0n == 0n : Nat}):
  specialized(~True{})

def false_specialization() -> S.When(False{},{0n == 0n : Nat}):
  specialized(~False{})

def delayed(guard: Bool) -> Unit -> S.When(guard,{0n == 0n : Nat}):
  _ => introduce(guard)

def GuardWitness(-guard: Bool) -> Type:
  &actual: Bool -> {actual == guard : Bool}

def live_witness(+guard: Bool) -> GuardWitness(guard):
  (guard,{==})

def Constant(-guard: Bool) -> Type:
  Unit

def constant_inhabitant(-guard: Bool) -> Constant(guard):
  Unit{}

def SameBranches(guard: Bool) -> Type:
  match guard:
    case False{}: Unit
    case True{}: Unit
