import Base
# The two systems retain distinct affine capture shapes.
type QueryPack is Type:
  QueryPack{calls:Array<U32>,values:Array<U32>}
def increment(+delta:U32,values:Array<U32>) -> Array<U32>:
  match values:
    case ALeaf{value}:ALeaf{(value + delta : U32)}
    case ANode{left,right}:ANode{increment(delta,left),increment(delta,right)}
def update(value:U32,pack:QueryPack) -> QueryPack:
  match pack:
    case QueryPack{calls,values}:QueryPack{increment(1,calls),increment(value,values)}
