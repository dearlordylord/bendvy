import Base
import ../../../src/ecs/entity-key.bend as K
import ../../../src/ecs/entity-allocator.bend as A

def key_text(value:K.Key) -> String:
  match value:
    case K.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def phase(value:A.Phase) -> String:
  match value:
    case A.Consumed{}:"Consumed"
    case A.Pending{}:"Pending"
    case A.Live{}:"Live"
    case A.DeadRetained{}:"DeadRetained"
    case A.Free{}:"Free"
def slot(value:A.Slot) -> A.Slot & String:
  match value:
    case A.Slot{+generation,+value}:(A.Slot{generation,value},U32.show(generation) ++ ":" ++ phase(value))
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<A.Slot> & String) -> A.Allocator & String:
  match observed:
    case (slots,text):(A.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,K.Key,key_text,order))
def allocator(value:A.Allocator) -> A.Allocator & String:
  match value:
    case A.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,array(~A.Slot,~slot,slots))
