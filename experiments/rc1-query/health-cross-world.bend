import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def bad() -> A.World<S.HealthToken, S.CombatCell> & String:
  A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Optional{}, S.motion())
