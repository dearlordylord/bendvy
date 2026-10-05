import Base
# Local frozen-element recursion avoids open erased Array helper code generation.
def left(~P: Type,right: Array<P>,result: Array<P> & P) -> Array<P> & P:
  match result:
    case (left,value): (ANode{left,right},value)
def right(~P: Type,left: Array<P>,result: Array<P> & P) -> Array<P> & P:
  match result:
    case (right,value): (ANode{left,right},value)
def swap_go(~P: Type,array: Array<P>,+capacity: U32,+index: U32,value: P,low: Bool) -> Array<P> & P:
  match array low:
    case ALeaf{old} _: (ALeaf{value},old)
    case ANode{xs,ys} True{}: left(P,ys,swap_go(P,xs,U32.shr(capacity),index,value,U32.is_lt(index,U32.shr(U32.shr(capacity)))))
    case ANode{xs,ys} False{}: right(P,xs,swap_go(P,ys,U32.shr(capacity),U32.sub(index,U32.shr(capacity)),value,U32.is_lt(U32.sub(index,U32.shr(capacity)),U32.shr(U32.shr(capacity)))))
def get_go(~P: Data,array: Array<P>,+capacity: U32,+index: U32,low: Bool) -> Array<P> & P:
  match array low:
    case ALeaf{+value} _: (ALeaf{value},value)
    case ANode{xs,ys} True{}: left(P,ys,get_go(P,xs,U32.shr(capacity),index,U32.is_lt(index,U32.shr(U32.shr(capacity)))))
    case ANode{xs,ys} False{}: right(P,xs,get_go(P,ys,U32.shr(capacity),U32.sub(index,U32.shr(capacity)),U32.is_lt(U32.sub(index,U32.shr(capacity)),U32.shr(U32.shr(capacity)))))
def get(~P: Data,array: Array<P>,+capacity: U32,+index: U32) -> Array<P> & P:
  get_go(P,array,capacity,index,U32.is_lt(index,U32.shr(capacity)))
def swap(~P: Type,array: Array<P>,+capacity: U32,+index: U32,value: P) -> Array<P> & P:
  swap_go(P,array,capacity,index,value,U32.is_lt(index,U32.shr(capacity)))
def set_done(~P: Type,result: Array<P> & P) -> Array<P>:
  match result:
    case (array,_): array
def set(~P: Type,array: Array<P>,+capacity: U32,+index: U32,value: P) -> Array<P>:
  set_done(P,swap(P,array,capacity,index,value))
