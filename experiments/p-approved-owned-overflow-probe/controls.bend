import Base
import ./bridge.bend as P
import ../p-approved-owned-safety/member-safety.bend as G
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

def describe_positive() -> {S.describe(T.Any{},Some{T.Row{0n,0n,False{}}}) == T.Found{T.Row{0n,0n,False{}}} : T.Lookup}:
  P.describe_any(0n,0n,False{})
def source_positive() -> {G.row_safe(G.Overflow{},T.Row{0n,0n,False{}}) == S.no_overflow_lookup(S.describe(T.Any{},Some{T.Row{0n,0n,False{}}})) : Bool}:
  P.source_row(T.Row{0n,0n,False{}})
def observed_positive() -> {S.no_overflow_lookup(S.describe(T.Any{},Some{T.Row{0n,0n,False{}}})) == S.no_overflow_lookup(T.Found{T.Row{0n,0n,False{}}}) : Bool}:
  P.overflow_found(0n,0n,False{})
