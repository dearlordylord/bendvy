import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

def found_scalar_nat(+id: Nat,+value: Nat,+tag: Bool) -> {S.no_overflow_lookup(T.Found{T.Row{id,value,tag}}) == Bool.not(Nat.is_ge(value,U32.to_nat(4294967295))) : Bool}:
  {==}
