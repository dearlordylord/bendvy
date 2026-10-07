import Base
import ../public.bend as Public
import ../../../../src/ecs/capabilities.bend as Cap
import support.bend as P
def body(~H:Type,~cap:Cap.Read<H,Unit>,input:Array<U32>,ctx:H) -> H & Array<U32>:
  Public.apply(~H,~Array<U32>,~Array<U32>,~cap,ctx,input)
def bad(owner:P.Owner,input:Array<U32>) -> P.Owner & Array<U32>:
  Public.provide(~P.Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~P.request,~body,input,owner)
