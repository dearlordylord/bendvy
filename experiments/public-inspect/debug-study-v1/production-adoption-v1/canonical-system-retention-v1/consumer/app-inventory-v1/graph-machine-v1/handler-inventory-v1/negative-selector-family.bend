import Base
import ../types.bend as T
import ../../../../../../../../../src/ecs/machine-handler-bundle.bend as B
type OtherKey is Data:
  OtherKey{}
def wrong(value:B.Selector<T.Tag,OtherKey,T.State>) -> B.Selector<T.Tag,T.Key,T.State>:
  value
def main() -> Unit:
  Unit{}
