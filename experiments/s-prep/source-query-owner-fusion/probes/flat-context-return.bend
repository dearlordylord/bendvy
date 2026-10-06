import Base

def finish(a:Array<U32>,b:Array<U32>,index:U32,owner:Array<U32>,aux:Array<U32>,value:U32) -> Array<U32> & (Array<U32> & (Array<U32> & (Array<U32> & U32))):
  (Array.set(U32,a,index,value),(b,(owner,(aux,8))))
def bridge(~P:Type,~U:Type,~C0:Type,~C1:Type,~C2:Type,~Out:Type,~done:C0 -> C1 -> C2 -> P -> U -> U32 -> Out,c0:C0,c1:C1,c2:C2,owner:P,aux:U) -> Out:
  done(c0,c1,c2,owner,aux,7)
def apply(~client:@-P:Type -> @-U:Type -> @-C0:Type -> @-C1:Type -> @-C2:Type -> @-Out:Type -> @-done:(C0 -> C1 -> C2 -> P -> U -> U32 -> Out) -> C0 -> C1 -> C2 -> P -> U -> Out,a:Array<U32>,b:Array<U32>,owner:Array<U32>,aux:Array<U32>) -> Array<U32> & (Array<U32> & (Array<U32> & (Array<U32> & U32))):
  client(Array<U32>,Array<U32>,Array<U32>,Array<U32>,U32,Array<U32> & (Array<U32> & (Array<U32> & (Array<U32> & U32))),finish,a,b,0,owner,aux)
def main() -> Array<U32> & (Array<U32> & (Array<U32> & (Array<U32> & U32))):
  apply(~bridge,[0:U32^2n],[1:U32^2n],[2:U32^2n],[3:U32^2n])
