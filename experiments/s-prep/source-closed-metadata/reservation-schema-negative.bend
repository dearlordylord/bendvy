import Base
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/commands.bend as C
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/types.bend as T
type Raw is Type:
  Raw{payload:Array<U32>}
def bad(world:S.World<T.MotionSchema,Raw,Raw,U32,Raw,U32>,handle:S.Handle<T.HealthSchema>,bundle:S.Bundle<Raw,Raw,U32>) -> T.Reservation<S.World<T.MotionSchema,Raw,Raw,U32,Raw,U32>,S.Handle<T.MotionSchema>,S.Bundle<Raw,Raw,U32>>:
  C.prototype_closed_reserved(~Raw,~Raw,~U32,T.MotionSchema,Raw,U32,bundle,(world,Some{handle}))
def main() -> U32: 0
