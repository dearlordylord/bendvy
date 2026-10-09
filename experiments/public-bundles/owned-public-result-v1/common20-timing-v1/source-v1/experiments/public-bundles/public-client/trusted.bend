import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/public.bend as P
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/combined-other.bend as B
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-pack.bend as PackPack
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W
type Observation is Data:
  Observation{errors:List<&2,Maybe<&2,String>>}
def observed(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,+errors},events,commands,regs,system,clock}: (W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock},Observation{errors})
def request(world:W.World<A.Schema,A.Store,A.Mail,U32>,payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Observation:
  observed(A.eager(world,payload))
def finished(observed:W.World<A.Schema,A.Store,A.Mail,U32> & Unit) -> String:
  match observed:
    case (world,Unit{}): A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world))
