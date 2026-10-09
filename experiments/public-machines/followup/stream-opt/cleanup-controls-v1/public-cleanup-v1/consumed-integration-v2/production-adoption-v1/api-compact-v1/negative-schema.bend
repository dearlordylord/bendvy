import Base
import positive.bend as P
import system-instance.bend as Managed
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def wrong(instance:Managed.Instance<P.SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,P.body(~P.SchemaA),P.Ports,P.validate,P.remove(~P.SchemaA)>,world:W.World<P.SchemaB,Unit,Unit,Unit>) -> Managed.RunResult<P.SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,P.body(~P.SchemaA),P.Ports,P.validate,P.remove(~P.SchemaA)>:
  P.run_a(instance,world)
def main() -> Unit:
  Unit{}
