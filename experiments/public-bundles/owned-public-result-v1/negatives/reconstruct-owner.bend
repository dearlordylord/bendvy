import Base
import ../public.bend as Public
import support.bend as P
def body(~H:Type,~cap:Public.Request<H,Array<U32>,Array<U32>>,input:Array<U32>,ctx:H) -> H & Array<U32>:
  Public.apply(~H,~Array<U32>,~Array<U32>,~cap,P.Owner{ALeaf{99}},input)
def bad(owner:P.Owner,input:Array<U32>) -> P.Owner & Array<U32>:
  Public.provide(~P.Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~P.request,~body,input,owner)
