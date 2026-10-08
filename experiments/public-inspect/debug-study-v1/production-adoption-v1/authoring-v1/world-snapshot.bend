import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ../../description-v1/full-dto-v1/owner-observation.bend as Owner
import ../../description-v1/full-dto-v1/world-snapshot.bend as Original
# The original complete physical fixture snapshot omits namespace. This wrapper
# retains that original text and adds the actual owner-returned namespace.
def joined(namespace:U32,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  match result:
    case (world,text):(world,U32.show(namespace)++"|"++text)
def named(result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & U32) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  match result:
    case (world,namespace):joined(namespace,Original.project(world))
def project(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String:
  named(W.namespace(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,world))
