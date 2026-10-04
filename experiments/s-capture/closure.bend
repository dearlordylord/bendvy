import Base
import ./local.bend as L
# Each closure is called once and returns its captured owner.
# A factory can then create a fresh closure from that owner for the next run.
def make(local: L.Local) -> Unit -> L.Local & U32:
  _ => L.invoke(local)
def invoke(local: L.Local) -> L.Local & U32:
  make(local)(Unit{})
def show(y: U32, result: L.Local & U32) -> String:
  match result:
    case (_, x): U32.show(x) ++ "," ++ U32.show(y)
def other(first: L.Local, result: L.Local & U32) -> String:
  match result:
    case (_, y): show(y, make(first)(Unit{}))
def finish(second: L.Local, result: L.Local & U32) -> String:
  match result:
    case (first, _): other(first, make(second)(Unit{}))
def main() -> String:
  finish(L.initial(), make(L.initial())(Unit{}))
