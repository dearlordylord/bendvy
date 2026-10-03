import Base
import ./schemas.bend as S

# Application callbacks receive arbitrary affine handles and declared operations.
def motion_aux(-P: Type, -M: Type, text: String, p: P, m: M & Maybe<&2, S.Tag>) -> P & (M & String):
  match m:
    case (m, tag): (p, (m, text ++ S.tag_show(tag) ++ ";"))
def motion_finish(-P: Type, -M: Type, label: String, p: P & U32, m: M & Maybe<&2, S.Tag>) -> P & (M & String):
  match p:
    case (p, x): motion_aux(P, M, label ++ ":" ++ U32.show(x) ++ ":", p, m)
def motion_read(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  motion_finish(P, M, label, get(p, S.Position{}), aux(m))
def motion_update(-P: Type, -M: Type, set: P -> S.MotionToken -> U32 -> P, after: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, before: P & U32, m: M) -> P & (M & String):
  match before:
    case (p, x): motion_finish(P, M, label, after(set(p, S.Position{}, (x + 1 : U32)), S.Position{}), aux(m))
def motion_step(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, set: P -> S.MotionToken -> U32 -> P, after: P -> S.MotionToken -> P & U32, aux: M -> M & Maybe<&2, S.Tag>, label: String, p: P, m: M) -> P & (M & String):
  motion_update(P, M, set, after, aux, label, get(p, S.Position{}), m)

def health_aux(-P: Type, -M: Type, text: String, p: P, m: M & S.CombatData) -> P & (M & String):
  match m:
    case (m, S.CombatData{damage, armor}): (p, (m, text ++ U32.show(damage) ++ ":" ++ S.armor_show(armor) ++ ";"))
def health_finish(-P: Type, -M: Type, label: String, p: P & U32, m: M & S.CombatData) -> P & (M & String):
  match p:
    case (p, x): health_aux(P, M, label ++ ":" ++ U32.show(x) ++ ":", p, m)
def health_read(-P: Type, -M: Type, get: P -> S.HealthToken -> P & U32, aux: M -> M & S.CombatData, label: String, p: P, m: M) -> P & (M & String):
  health_finish(P, M, label, get(p, S.HitPoints{}), aux(m))
def health_after(-P: Type, -M: Type, after: P -> S.HealthToken -> P & U32, label: String, p: P, m: M, data: S.CombatData) -> P & (M & String):
  health_finish(P, M, label, after(p, S.HitPoints{}), (m, data))
def health_damage(-P: Type, -M: Type, set: P -> S.HealthToken -> U32 -> P, after: P -> S.HealthToken -> P & U32, label: String, p: P, x: U32, m: M & S.CombatData) -> P & (M & String):
  match m:
    case (m, S.CombatData{+damage, armor}): health_after(P, M, after, label, set(p, S.HitPoints{}, (x - damage : U32)), m, S.CombatData{damage, armor})
def health_update(-P: Type, -M: Type, set: P -> S.HealthToken -> U32 -> P, after: P -> S.HealthToken -> P & U32, label: String, p: P & U32, m: M & S.CombatData) -> P & (M & String):
  match p:
    case (p, x): health_damage(P, M, set, after, label, p, x, m)
def health_step(-P: Type, -M: Type, get: P -> S.HealthToken -> P & U32, set: P -> S.HealthToken -> U32 -> P, after: P -> S.HealthToken -> P & U32, aux: M -> M & S.CombatData, label: String, p: P, m: M) -> P & (M & String):
  health_update(P, M, set, after, label, get(p, S.HitPoints{}), aux(m))
