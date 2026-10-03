import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def looked(-P: Type, -M: Type, result: A.World<S.HealthToken, S.CombatCell> & A.LookupResult, p: P, m: M) -> P & (M & String):
  match result:
    case (_, _): (p, (m, ""))
def bad(-P: Type, -M: Type, get: P -> S.HealthToken -> P & U32, aux: M -> M & S.CombatData, label: String, p: P, m: M) -> P & (M & String):
  looked(P, M, A.lookup(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Optional{}, "b", S.health()), p, m)
