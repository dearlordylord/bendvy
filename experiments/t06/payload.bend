# Owned payload and projection copied from verified T04; no full-world import.
import Base

type Payload is Type:
  Payload{items: Array<U32>}
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
