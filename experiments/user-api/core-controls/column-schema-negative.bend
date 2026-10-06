import Base
import ../../../src/ecs/column.bend as K
type A is Data:
  A{}
type B is Data:
  B{}
def main() -> K.Column<B,U32>:
  K.empty(~A,~U32)
