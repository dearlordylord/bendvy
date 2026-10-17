import Base
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../examples/scheduled-health/components.bend as D
import ../../../src/ecs/transaction.bend as T
def failed(~H:Type,value:H & (T.Outcome<Decay.Error> & D.Health)) -> H & (T.Outcome<Decay.Error> & D.Health):
  match value:
    case (owner,(_,health)):(owner,(T.Failure{Decay.MissingComponent{}},health))
def body(~H:Type,~caps:Decay.PairOps(H),args:Unit,owner:H) -> H & (T.Outcome<Decay.Error> & D.Health):
  failed(~H,Decay.decay_body(~H,~caps,args,owner))
