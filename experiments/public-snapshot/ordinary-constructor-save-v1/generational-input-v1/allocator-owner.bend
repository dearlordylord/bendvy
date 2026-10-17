import Base
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/entity-allocator.bend as A
import ../../../../src/ecs/decode-data.bend as D

def key(value:K.Key) -> D.Raw:
  match value:
    case K.EntityKey{index,generation}:D.Object{[D.Field{"index",D.Number{index}},D.Field{"generation",D.Number{generation}}]}
def keys(values:List<&2,K.Key>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case value <> rest:key(value) <> keys(rest)
def numbers(values:List<&2,U32>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case value <> rest:D.Number{value} <> numbers(rest)
def phase(value:A.Phase) -> String:
  match value:
    case A.Consumed{}:"Consumed"
    case A.Pending{}:"Pending"
    case A.Live{}:"Live"
    case A.DeadRetained{}:"DeadRetained"
    case A.Free{}:"Free"
def slot(+value:A.Slot) -> A.Slot & D.Raw:
  match value:
    case A.Slot{+generation,+state}:(A.Slot{generation,state},D.Object{[D.Field{"generation",D.Number{generation}},D.Field{"phase",D.Text{phase(state)}}]})
def leaf(observed:A.Slot & D.Raw) -> Array<A.Slot> & D.Raw:
  match observed:
    case (value,raw):(ALeaf{value},D.Object{[D.Field{"ALeaf",raw}]})
def joined(left:Array<A.Slot> & D.Raw,right:Array<A.Slot> & D.Raw) -> Array<A.Slot> & D.Raw:
  (left,lr)=left
  (right,rr)=right
  (ANode{left,right},D.Object{[D.Field{"ANode",D.Array{[lr,rr]}}]})
def tree(value:Array<A.Slot>) -> Array<A.Slot> & D.Raw:
  match value:
    case ALeaf{value}:leaf(slot(value))
    case ANode{left,right}:joined(tree(left),tree(right))
def restored(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<A.Slot> & D.Raw) -> A.Allocator & D.Raw:
  match observed:
    case (slots,raw):(A.Allocator{next,high,slots,capacity,depth,free,order},D.Object{[D.Field{"next",D.Number{next}},D.Field{"high",D.Number{high}},D.Field{"capacity",D.Number{capacity}},D.Field{"depth",D.Number{U32.from_nat(depth)}},D.Field{"slots",raw},D.Field{"free",D.Array{numbers(free)}},D.Field{"order",D.Array{keys(order)}}]})
def observe(value:A.Allocator) -> A.Allocator & D.Raw:
  match value:
    case A.Allocator{next,high,slots,capacity,depth,free,order}:restored(next,high,capacity,depth,free,order,tree(slots))
