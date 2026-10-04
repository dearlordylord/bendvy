import Base
import ./bridge.bend as P
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

def wrong_describe_result() -> {S.describe(T.Any{},Some{T.Row{0n,0n,False{}}}) == T.Missing{} : T.Lookup}:
  P.describe_any(0n,0n,False{})
