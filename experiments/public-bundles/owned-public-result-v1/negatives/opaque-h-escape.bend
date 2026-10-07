import Base
import ../public.bend as Public
import support.bend as P
# Body output is closed before H; H cannot escape as the owned result.
def body(~H:Type,~cap:Public.Request<H,Array<U32>,Array<U32>>,args:Array<U32>,ctx:H) -> H & (H -> H):
  (ctx,other => other)
def bad(owner:P.Owner,input:Array<U32>) -> P.Owner & Array<U32>:
  Public.provide(~P.Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~P.request,~body,input,owner)
