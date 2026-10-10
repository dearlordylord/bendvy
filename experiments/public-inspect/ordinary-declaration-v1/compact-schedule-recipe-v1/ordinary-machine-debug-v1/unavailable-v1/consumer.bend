import Base
import ../consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
# Existing Missing slot is a supplied ordinary resource value, not a new admission policy.
def scenario(~S:Data,count:Nat) -> String:
  Consumer.created(~S,count,W.create(~S,~Unit,~Consumer.Resource<S>,~U32,unit=>unit,W.factory(),Consumer.Resource{M.Missing{},Array.set(U32,Array.new(U32,1n,41),1,42)}))
