import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-provider.bend as Public
type Owner is Type:
  Owner{cells:Array<U32>}
def request(owner:Owner,input:Array<U32>) -> Owner & Array<U32>:
  (owner,input)
def body(~H:Type,~cap:Owned.OwnedRequest<H,Array<U32>,Array<U32>>,args:Array<U32>,ctx:H) -> H & Array<U32>:
  Owned.owned_request(~H,~Array<U32>,~Array<U32>,~cap,ctx,args)
def good(owner:Owner,input:Array<U32>) -> Owner & Array<U32>:
  Public.provide_owned(~Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~request,~body,input,owner)
