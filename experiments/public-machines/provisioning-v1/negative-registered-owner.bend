import Base
import declared.bend as D
import scene/provider.bend as P
import scene/application.bend as A
import ../../../../../bendvy/src/ecs/world.bend as W

def wrong(owners: A.Owners<P.SchemaA>,first: W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,second: W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,+plan: D.Plan<P.SchemaA>) -> A.FrameResult<P.SchemaA> & A.FrameResult<P.SchemaA>:
  (D.frame(~P.SchemaA,owners,first,plan),D.frame(~P.SchemaA,owners,second,plan))
def main() -> Unit:
  Unit{}
