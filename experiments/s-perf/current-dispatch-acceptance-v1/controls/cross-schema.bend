import Base
import ../subject/body.bend as B
import ../../canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/ordinary-capture-query.bend as O
type Other is Data:
  Other{}
def refused(world:W.World<Other,F.Store(),F.Resources(),Nat>) -> O.Registration<F.World(),B.Owned(),P.Pack>:B.define(world)
