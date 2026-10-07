import Base
import capability-leaf.bend as Owned
import witness.bend as W
# U is fixed to Array<U32> before H, rejecting an H-dependent result.
def escape(~H:Type,~cap:Owned.OwnedRequest<H,Array<U32>,Array<U32>>,args:Array<U32>,ctx:H) -> H & (H -> H):
  (ctx,other => other)
def bad(owner:W.Owner,input:Array<U32>) -> W.Owner & Array<U32>:
  Owned.invoke_owned(~h => Owned.OwnedRequest<h,Array<U32>,Array<U32>>,~Array<U32>,~Array<U32>,~escape,~W.Owner,~Owned.OwnedRequest{W.request(~Array<U32>)},input,owner)
