import Base
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

type Payload is Type:
  Payload{items: Array<U32>}
type Token is Data:
  Items{}
type OtherToken is Data:
  Foreign{}

def show4(r: Array<U32> & U32, text: String, i: U32) -> Array<U32> & String:
  match r:
    case (a, x): (a, text ++ U32.show(x))
def project_last(r: Array<U32> & U32, text: String) -> Array<U32> & String:
  match r:
    case (a, x): show4(Array.get(U32, a, 3), text ++ U32.show(x) ++ ",", 3)
def project_mid(r: Array<U32> & U32, text: String) -> Array<U32> & String:
  match r:
    case (a, x): project_last(Array.get(U32, a, 2), text ++ U32.show(x) ++ ",")
def project_first(r: Array<U32> & U32) -> Array<U32> & String:
  match r:
    case (a, x): project_mid(Array.get(U32, a, 1), U32.show(x) ++ ",")
def restore(r: Array<U32> & String) -> Payload & String:
  match r:
    case (a, text): (Payload{a}, text)
def get(c: Payload) -> Payload & String:
  match c:
    case Payload{a}: restore(project_first(Array.get(U32, a, 0)))
def has(c: Payload) -> Payload & Bool:
  (c, True{})
def update_value(r: Array<U32> & U32, delta: U32) -> Payload:
  match r:
    case (a, x): Payload{Array.set(U32, a, 1, (x + delta : U32))}
def update(c: Payload, token: Token, delta: U32) -> Payload:
  match c:
    case Payload{a}: update_value(Array.get(U32, a, 1), delta)
def world() -> A.World<S.MotionToken, Payload>:
  A.World{[A.Row{"a", A.Cell{0}, Payload{[10 : U32^2n]}}, A.Row{"b", A.Cell{10}, Payload{[20 : U32^2n]}}]}

# Extension of R-C1 traversal, retaining its abstract row handles and restoration.
def write_row(~callback: @-M: Type -> (M -> Token -> U32 -> M) -> M -> M, row: A.Row<S.MotionToken, Payload>) -> A.Row<S.MotionToken, Payload>:
  match row:
    case A.Row{label, cell, payload}: A.Row{label, cell, callback(Payload, update, payload)}
def write_rows(~callback: @-M: Type -> (M -> Token -> U32 -> M) -> M -> M, rows: List<A.Row<S.MotionToken, Payload>>) -> List<A.Row<S.MotionToken, Payload>>:
  match rows:
    case Nil{}: Nil{}
    case Con{row, tail}: write_row(~callback, row) <> write_rows(~callback, tail)
def writable(~callback: @-M: Type -> (M -> Token -> U32 -> M) -> M -> M, w: A.World<S.MotionToken, Payload>) -> A.World<S.MotionToken, Payload>:
  match w:
    case A.World{rows}: A.World{write_rows(~callback, rows)}
