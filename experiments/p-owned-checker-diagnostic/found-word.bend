import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S
import ../p-approved-owned-word-context/helpers.bend as W
import ./found-neutral.bend as F

def found_word(+id: U32,+value: U32,+tag: Bool) -> {S.no_overflow_lookup(T.Found{T.Row{U32.to_nat(id),U32.to_nat(value),tag}}) == U32.is_lt(value,4294967295) : Bool}:
  Equal.trans(Bool,S.no_overflow_lookup(T.Found{T.Row{U32.to_nat(id),U32.to_nat(value),tag}}),Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))),U32.is_lt(value,4294967295),F.found_scalar_nat(U32.to_nat(id),U32.to_nat(value),tag),W.bump_guard_agrees(value))
