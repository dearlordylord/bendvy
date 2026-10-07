import Base
import ../public.bend as Public
import ../adapter.bend as AD
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def bad(~H:Type,~cap:Public.Request<H,AD.Input<Schema,Array<U32>>,Array<U32>>,ctx:H,input:AD.Input<Other,Array<U32>>) -> H & Array<U32>:
  Public.apply(~H,~AD.Input<Schema,Array<U32>>,~Array<U32>,~cap,ctx,input)
