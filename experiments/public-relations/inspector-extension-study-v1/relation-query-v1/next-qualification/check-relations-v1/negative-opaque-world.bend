import Base
import ../../core-v1/src/ecs/check.bend as K

# The gameplay H is abstract: a declared read does not reveal World ownership.
def refused(~H:Type,owner:H) -> H:
  match owner:
    case K.Frame{world}:K.Frame{world}
def main() -> Nat:
  0n
