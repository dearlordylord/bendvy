import Base
import schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

def observed(~H:Type,value:H & U32) -> H & (T.Outcome<Decay.Error> & D.Health):
  match value:
    case (owner,_):(owner,(T.Success{},D.Health{0.0}))
def denied(~H:Type,~caps:Decay.PairOps(H),args:Unit,owner:H) -> H & (T.Outcome<Decay.Error> & D.Health):
  observed(~H,W.namespace(~S.Schema,~S.Store,~S.Resources,~Unit,owner))
