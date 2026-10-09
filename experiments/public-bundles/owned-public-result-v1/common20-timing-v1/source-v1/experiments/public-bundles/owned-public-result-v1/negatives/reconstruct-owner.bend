import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-provider.bend as Public
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/owned-public-result-v1/negatives/support.bend as P
def body(~H:Type,~cap:Owned.OwnedRequest<H,Array<U32>,Array<U32>>,input:Array<U32>,ctx:H) -> H & Array<U32>:
  Owned.owned_request(~H,~Array<U32>,~Array<U32>,~cap,P.Owner{ALeaf{99}},input)
def bad(owner:P.Owner,input:Array<U32>) -> P.Owner & Array<U32>:
  Public.provide_owned(~P.Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~P.request,~body,input,owner)
