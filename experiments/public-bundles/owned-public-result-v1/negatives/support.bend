import Base
import ../public.bend as Public
type Owner is Type:
  Owner{cells:Array<U32>}
def request(owner:Owner,input:Array<U32>) -> Owner & Array<U32>:
  (owner,input)
def body(~H:Type,~cap:Public.Request<H,Array<U32>,Array<U32>>,args:Array<U32>,ctx:H) -> H & Array<U32>:
  Public.apply(~H,~Array<U32>,~Array<U32>,~cap,ctx,args)
def good(owner:Owner,input:Array<U32>) -> Owner & Array<U32>:
  Public.provide(~Owner,~Array<U32>,~Array<U32>,~Array<U32>,~Array<U32>,~request,~body,input,owner)
