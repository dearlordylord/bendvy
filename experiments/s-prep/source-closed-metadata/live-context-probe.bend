import Base

def finish(-F:Data,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,live:Array<Bool>,value:Bool) -> (Array<Bool> & Array<Maybe<&2,F>>) & (Array<U32> & (Array<U32> & Bool)):
  ((live,flags),(added,(changed,value)))
def bridge(~C0:Type,~C1:Type,~C2:Type,~Out:Type,~done:C0 -> C1 -> C2 -> Array<Bool> -> Bool -> Out,c0:C0,c1:C1,c2:C2,result:Array<Bool> & Bool) -> Out:
  match result:
    case (live,value): done(c0,c1,c2,live,value)
def apply(~client:@-C0:Type -> @-C1:Type -> @-C2:Type -> @-Out:Type -> @-done:(C0 -> C1 -> C2 -> Array<Bool> -> Bool -> Out) -> C0 -> C1 -> C2 -> (Array<Bool> & Bool) -> Out,-F:Data,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,live:Array<Bool>) -> (Array<Bool> & Array<Maybe<&2,F>>) & (Array<U32> & (Array<U32> & Bool)):
  client(Array<Maybe<&2,F>>,Array<U32>,Array<U32>,(Array<Bool> & Array<Maybe<&2,F>>) & (Array<U32> & (Array<U32> & Bool)),finish(F),flags,added,changed,Array.get(Bool,live,0))
def main() -> (Array<Bool> & Array<Maybe<&2,U32>>) & (Array<U32> & (Array<U32> & Bool)):
  apply(~bridge,U32,[None{}:Maybe<&2,U32>^0n],[1:U32^0n],[2:U32^0n],[True{}:Bool^0n])
