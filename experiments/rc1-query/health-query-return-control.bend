import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def nested(-P: Type, -M: Type, result: A.World<S.HealthToken, S.CombatCell> & String, p: P, m: M) -> P & (M & String):
  match result:
    case (_, text): (p, (m, text))
def bad(-P: Type, -M: Type, get: P -> S.HealthToken -> P & U32, aux: M -> M & S.CombatData, label: String, p: P, m: M) -> P & (M & String):
  nested(P, M, A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Optional{}, S.health()), p, m)
