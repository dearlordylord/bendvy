import Base
import ./consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type First is Data:
  First{}
type Second is Data:
  Second{}
def second(rows:List<&2,String>,result:W.Factory & List<&2,String>) -> List<&2,String>:
  match result:
    case (W.Factory{next},other):List.append(&2,String,rows,List.append(&2,String,other,["Factory=" ++ U32.show(next)]))
def first(result:W.Factory & List<&2,String>) -> List<&2,String>:
  match result:
    case (factory,rows):second(rows,C.begin(~Second,factory))
def main() -> List<&2,String>:first(C.begin(~First,W.factory()))
