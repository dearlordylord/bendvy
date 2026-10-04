import Base
import ../p-approved-owned-safety/member-safety.bend as G
import ../p-approved-owned-word-context/helpers.bend as W
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

def goal(+id: U32, +value: U32, +tag: Bool) -> {G.row_safe(G.Overflow{},T.Row{U32.to_nat(id),U32.to_nat(value),tag}) == U32.is_lt(value,4294967295) : Bool}:
  ?TODO
