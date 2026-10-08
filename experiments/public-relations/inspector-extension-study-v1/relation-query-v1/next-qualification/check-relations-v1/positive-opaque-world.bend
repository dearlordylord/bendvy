import Base
import ../../core-v1/src/ecs/check.bend as K

# The gameplay H is abstract: a declared read does not reveal World ownership.
def legal(~S:Data,~Store:Type,~R:Type,~E:Data,owner:K.Frame<S,Store,R,E>) -> K.Frame<S,Store,R,E>:
  match owner:
    case K.Frame{world}:K.Frame{world}
def main() -> Nat:
  0n
