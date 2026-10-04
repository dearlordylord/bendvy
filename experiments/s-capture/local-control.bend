import Base
import ./local.bend as L
def show(y: U32, result: L.Local & U32) -> String:
  match result:
    case (_, x): U32.show(x) ++ "," ++ U32.show(y)
def finish(first: L.Local, x: U32, result: L.Local & U32) -> String:
  match result:
    case (_, y): show(y, L.invoke(first))
def second(other: L.Local, result: L.Local & U32) -> String:
  match result:
    case (first, x): finish(first, x, L.invoke(other))
def main() -> String:
  second(L.initial(), L.invoke(L.initial()))
