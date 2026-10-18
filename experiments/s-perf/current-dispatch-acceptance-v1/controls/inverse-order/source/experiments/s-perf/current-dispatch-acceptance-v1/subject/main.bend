import Base
import ./scenario.bend as S
import ../../canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../../canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world-io.bend as WI
def created(value:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(S.start(world))
    case _:IO.die(Unit,1,"World creation failed")
def main() -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),created)
