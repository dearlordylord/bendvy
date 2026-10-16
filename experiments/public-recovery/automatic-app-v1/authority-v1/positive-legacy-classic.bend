import Base
import ./legacy.bend as L
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
type First is Data:First{}
def positive(world:F.World(~First),capture:Array<Array<U32>>) -> System.Defined<F.World(~First),L.ClassicOwned(~First),Array<Array<U32>>>:L.classic_define(~First,world,capture)
