import Base
import ./dispatcher.bend as D

def runtime_map(-W:Type,-Handle:Data,apply:W -> W,state:D.Runtime<W,Handle>) -> D.Runtime<W,Handle>:
  match state:
    case D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}: D.Runtime{apply(world),registry,readers,clock,audit,style,escaped,observations,nextMode}
