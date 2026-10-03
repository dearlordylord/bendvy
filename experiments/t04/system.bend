import Base
import ../rc1-query/schemas.bend as S
import ./payload.bend as V

def finish_aux(-P: Type, -M: Type, text: String, p: P, m: M & String) -> P & (M & String):
  match m:
    case (m, values): (p, (m, text ++ "[" ++ values ++ "];"))
def finish(-P: Type, -M: Type, label: String, p: P & U32, m: M & String) -> P & (M & String):
  match p:
    case (p, x): finish_aux(P, M, label ++ ":" ++ U32.show(x) ++ ":", p, m)
def read(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & String, label: String, p: P, m: M) -> P & (M & String):
  finish(P, M, label, get(p, S.Position{}), aux(m))
def step(-M: Type, set: M -> V.Token -> U32 -> M, m: M) -> M:
  set(m, V.Items{}, 3)
def noop(-M: Type, set: M -> V.Token -> U32 -> M, m: M) -> M:
  m
