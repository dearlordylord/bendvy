import Base
import ../public.bend as Public
import support.bend as P
def again(~H:Type,~cap:Public.Request<H,Array<U32>,Array<U32>>,input:Array<U32>,seen:H & Array<U32>) -> H & Array<U32>:
  match seen:
    case (ctx,returned): Public.apply(~H,~Array<U32>,~Array<U32>,~cap,ctx,input)
def body(~H:Type,~cap:Public.Request<H,Array<U32>,Array<U32>>,input:Array<U32>,ctx:H) -> H & Array<U32>:
  again(~H,~cap,input,Public.apply(~H,~Array<U32>,~Array<U32>,~cap,ctx,input))
def bad(owner:P.Owner,input:Array<U32>) -> P.Owner & Array<U32>:
  Public.provide(~P.Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~P.request,~body,input,owner)
