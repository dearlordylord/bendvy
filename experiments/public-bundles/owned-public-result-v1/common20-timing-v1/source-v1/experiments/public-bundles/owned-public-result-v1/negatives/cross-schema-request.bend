import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-provider.bend as Public
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-insert-adapter.bend as AD
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def bad(~H:Type,~cap:Owned.OwnedRequest<H,AD.Input<Schema,Array<U32>>,Array<U32>>,ctx:H,input:AD.Input<Other,Array<U32>>) -> H & Array<U32>:
  Owned.owned_request(~H,~AD.Input<Schema,Array<U32>>,~Array<U32>,~cap,ctx,input)
