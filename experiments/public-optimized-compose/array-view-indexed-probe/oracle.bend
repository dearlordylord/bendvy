import Base
def array_join(left_view: Array<U32> & List<&2,U32>,right_view: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,+xs) = left_view
  (right,+ys) = right_view
  (ANode{left,right},List.append(&2,U32,xs,ys))
def array_view(array: Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{+value}: (ALeaf{value},value <> [])
    case ANode{left,right}: array_join(array_view(left),array_view(right))
def prefix(fuel: Nat,xs: List<&2,U32>) -> List<&2,U32>:
  match fuel xs:
    case 0n xs: []
    case _ Nil{}: []
    case 1n+rest Con{+x,xs}: x <> prefix(rest,xs)
