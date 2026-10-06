import Base

def presence(-M:Type,value:Maybe<M>) -> Maybe<M> & Bool:
  match value:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})
def leaf(-M:Type,result:Maybe<M> & Bool) -> Array<Maybe<M>> & Bool:
  match result:
    case Tuple{value,+present}: (ALeaf{value},present)
def lo(-M:Type,right:Array<Maybe<M>>,result:Array<Maybe<M>> & Bool) -> Array<Maybe<M>> & Bool:
  match result:
    case Tuple{left,+present}: (ANode{left,right},present)
def hi(-M:Type,left:Array<Maybe<M>>,result:Array<Maybe<M>> & Bool) -> Array<Maybe<M>> & Bool:
  match result:
    case Tuple{right,+present}: (ANode{left,right},present)
def go(-M:Type,array:Array<Maybe<M>>,+size:U32,+index:U32,lower:Bool) -> Array<Maybe<M>> & Bool:
  match array lower:
    case ALeaf{value} _: leaf(M,presence(M,value))
    case ANode{left,right} True{}:
      +half = U32.shr(size)
      lo(M,right,go(M,left,half,index,U32.is_lt(index,U32.shr(half))))
    case ANode{left,right} False{}:
      +half = U32.shr(size)
      +next = U32.sub(index,half)
      hi(M,left,go(M,right,half,next,U32.is_lt(next,U32.shr(half))))
def at(-M:Type,+index:U32,result:Array<Maybe<M>> & U32) -> Array<Maybe<M>> & Bool:
  match result:
    case Tuple{array,+size}:
      +actual = U32.and(index,U32.sub(size,1))
      go(M,array,size,actual,U32.is_lt(actual,U32.shr(size)))
def inspect(-M:Type,array:Array<Maybe<M>>,index:U32) -> Array<Maybe<M>> & Bool:
  at(M,index,Array.size(Maybe<M>,array))
def done(result:Array<Maybe<Array<U32>>> & Bool) -> U32:
  match result:
    case Tuple{array,+present}: release(present,Array.swap(Maybe<Array<U32>>,array,0,None{}))
def release(+present:Bool,result:Array<Maybe<Array<U32>>> & Maybe<Array<U32>>) -> U32:
  match result present:
    case Tuple{_,None{}} _: 0
    case Tuple{_,Some{owner}} True{}: finish(Array.get(U32,owner,0))
    case Tuple{_,Some{owner}} False{}: finish(Array.get(U32,owner,0))
def finish(result:Array<U32> & U32) -> U32:
  match result:
    case Tuple{_,+value}: value
def main() -> U32:
  done(inspect(Array<U32>,ALeaf{Some{[9:U32^0n]}},0))
