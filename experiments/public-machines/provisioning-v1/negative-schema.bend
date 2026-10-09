import Base
import declared.bend as D
import scene/provider.bend as P
import scene/application.bend as A
import ../../../../../bendvy/src/ecs/world.bend as W

def wrong(owners: A.Owners<P.SchemaA>,world: W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,plan: D.Plan<P.SchemaB>) -> A.FrameResult<P.SchemaA>:
  D.frame(~P.SchemaA,owners,world,plan)
def main() -> Unit:
  Unit{}
