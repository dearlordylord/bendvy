import Base
import ../../../src/ecs/event-runtime.bend as Ev

def append(~E:Data,+left:List<&2,E>,+right:List<&2,E>) -> List<&2,E>:
  match left right:
    case Nil{} right: right
    case left Nil{}: left
    case left right: Ev.append_loop(~E,List.reverse(&2,E,left),right)
