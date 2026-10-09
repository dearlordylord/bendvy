import Base
import ../types.bend as T
import ../../../../../../../../../../src/ecs/machine-handler-bundle.bend as B
type Other is Data:
  Other{}
def wrong(value:B.Selector<Other,T.Key,T.State>) -> B.Selector<T.Tag,T.Key,T.State>:
  value
def main() -> Unit:
  Unit{}
