import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# Trusted author supplies read-only operations over its arbitrary affine owner.
# Consumer is universal in H; its result Type is fixed BEFORE abstract H.
def provide(~Owner:Type,~Observation:Type,~at:Owner -> U32 -> Owner & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & Observation,owner:Owner) -> Owner & Observation:
  body(Owner,Cap.Request{at},owner)
def at(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H,index:U32) -> H & U32:
  Cap.request(~H,~U32,~U32,~read,owner,index)
