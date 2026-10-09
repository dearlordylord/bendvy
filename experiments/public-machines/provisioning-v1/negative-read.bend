import Base
import initial.bend as I
import scene/provider.bend as P
import ../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../bendvy/src/ecs/machine.bend as M
import ../../../../../bendvy/src/ecs/capabilities.bend as Cap

def wrong(~H: Type,read: Cap.ValueRead<H,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,world: W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>) -> I.Installation<W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,P.Flow>:
  I.install_empty(~P.SchemaA,~P.FlowToken,~P.Flow,~W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,~(w => P.flow_take(~P.SchemaA,w)),~(w => slot => P.flow_put(~P.SchemaA,w,slot)),read,world,P.Boot{})
def main() -> Unit:
  Unit{}
