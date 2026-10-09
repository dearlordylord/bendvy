import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/public.bend as P
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/public-client/trusted.bend as T
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-pack.bend as PackPack
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Cap
def done(-H:Type,observed:H & T.Observation) -> H & Unit:
  match observed:
    case (ctx,observation): (ctx,Unit{})
def run(-H:Type,cap:Cap.Request<H,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,T.Observation>,payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,ctx:H) -> H & Unit:
  done(H,P.apply(H,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,T.Observation,cap,payload,ctx))
