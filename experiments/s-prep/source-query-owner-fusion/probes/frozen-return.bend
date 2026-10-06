import Base

type Context is Type:
  Context{numbers:Array<U32>}

def finish(-P:Type,-U:Type,context:Context,owner:P,aux:U,value:U32) -> Context & (P & (U & U32)):
  (context,(owner,(aux,value)))
def bridge(~P:Type,~U:Type,~Ctx:Type,~Out:Type,~done:Ctx -> P -> U -> U32 -> Out,context:Ctx,owner:P,aux:U) -> Out:
  done(context,owner,aux,7)
def apply(~P:Type,~U:Type,~client:@-P:Type -> @-U:Type -> @-Ctx:Type -> @-Out:Type -> @-done:(Ctx -> P -> U -> U32 -> Out) -> Ctx -> P -> U -> Out,context:Context,owner:P,aux:U) -> Context & (P & (U & U32)):
  client(P,U,Context,Context & (P & (U & U32)),finish(P,U),context,owner,aux)
def main() -> Context & (Array<U32> & (Array<U32> & U32)):
  apply(~Array<U32>,~Array<U32>,~bridge,Context{[0:U32*2n]},[1:U32*2n],[2:U32*2n])
