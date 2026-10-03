import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad(-P: Type, -M: Type, get: P -> S.HealthToken -> P & U32, set: P -> S.HealthToken -> U32 -> P, after: P -> S.HealthToken -> P & U32, aux: M -> M & S.CombatData, label: String, p: P, m: M) -> P & (M & String):
  (A.cell_set(S.HealthToken, A.Cell{0}, S.HitPoints{}, 99), (m, ""))
