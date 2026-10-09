import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import ./world-namespace.bend as F

# Application create uses the shared emitted-program IO namespace effect.
# with_namespace/convert and raw World construction are trusted integration helpers.
# No language-wide constructor/authority confinement is claimed.
# Concrete World constructors remain a trusted schema/admin boundary.
type Creation<S: Data,C: Type,R: Type,E: Data> is Type:
  Created{world: W.World<S,C,R,E>}
  Refused{resource: R}

def convert(~S: Data,~C: Type,~R: Type,~E: Data,created: W.Creation<S,C,R,E>) -> Creation<S,C,R,E>:
  match created:
    case W.Created{_,world}: Created{world}
    case W.CreateRejected{_,resource}: Refused{resource}

def with_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,+namespace: U32,resource: R) -> IO(Creation<S,C,R,E>):
  IO.pure(Creation<S,C,R,E>,convert(~S,~C,~R,~E,W.create_checked(~S,~C,~R,~E,~empty,Bool.and(U32.is_lt(0,namespace),U32.is_lt(namespace,4294967295)),namespace,resource)))

def create(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,resource: R) -> IO(Creation<S,C,R,E>):
  IO.bind(U32,Creation<S,C,R,E>,F.fresh(),namespace => with_namespace(~S,~C,~R,~E,~empty,namespace,resource))
