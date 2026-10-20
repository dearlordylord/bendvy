import Base
import ./world.bend as W
import ./world-namespace.bend as F

# Ordinary creation uses the checked host IO namespace allocator.
# Canonical linked Native execution and a shared JS realm are qualified separately.
# with_namespace/convert and raw World construction are trusted integration helpers.
# No language-wide constructor/authority confinement is claimed.
# Concrete World constructors remain a trusted schema/admin boundary.
# World creation outcome: Created owns the new World; Refused returns the
# caller's resource owner without constructing a usable World.
type Creation<S: Data,C: Type,R: Type,E: Data> is Type:
  Created{world: W.World<S,C,R,E>}
  Refused{resource: R}

def convert(~S: Data,~C: Type,~R: Type,~E: Data,created: W.Creation<S,C,R,E>) -> Creation<S,C,R,E>:
  match created:
    case W.Created{_,world}: Created{world}
    case W.CreateRejected{_,resource}: Refused{resource}

# Trusted integration constructor with a caller-supplied namespace. Rejects
# reserved namespace values and returns the resource on refusal. Does not
# allocate a unique namespace: caller must prevent collisions. Prefer create.
def with_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,+namespace: U32,resource: R) -> IO(Creation<S,C,R,E>):
  IO.pure(Creation<S,C,R,E>,convert(~S,~C,~R,~E,W.create_checked(~S,~C,~R,~E,~empty,Bool.and(U32.is_lt(0,namespace),U32.is_lt(namespace,4294967295)),namespace,resource)))

# Create an independent World through the host IO namespace allocator.
# Consumes resource; Created returns its World, Refused returns resource.
# empty is trusted schema setup constructing component storage. Namespace
# uniqueness is scoped to the qualified host allocator realm/process, not
# arbitrary remote processes or raw constructors.
# Example: examples/scheduled-health/main.bend; identity: docs/parity/identity.md.
def create(~S: Data,~C: Type,~R: Type,~E: Data,~empty: Unit -> C,resource: R) -> IO(Creation<S,C,R,E>):
  IO.bind(U32,Creation<S,C,R,E>,F.fresh(),namespace => with_namespace(~S,~C,~R,~E,~empty,namespace,resource))
