import Base

type Pack is Type:
  Pack{first:Array<U32>,second:Array<U32>}
type Tree is Data:
  Leaf{value:U32}
  Node{left:Tree,right:Tree}
type Observation is Data:
  Observation{first:Tree,second:Tree}
def joined(a:Array<U32> & Tree,b:Array<U32> & Tree) -> Array<U32> & Tree:
  match a b:
    case (left,x), (right,y):(ANode{left,right},Node{x,y})
def observe(array:Array<U32>) -> Array<U32> & Tree:
  match array:
    case ALeaf{+value}:(ALeaf{value},Leaf{value})
    case ANode{leftArray,rightArray}:joined(observe(leftArray),observe(rightArray))
def observed_second(first:Array<U32>,a:Tree,result:Array<U32> & Tree) -> Pack & Observation:
  (second,b) = result
  (Pack{first,second},Observation{a,b})
def observed_first(second:Array<U32>,result:Array<U32> & Tree) -> Pack & Observation:
  (first,a) = result
  observed_second(first,a,observe(second))
def project(pack:Pack) -> Pack & Observation:
  match pack:
    case Pack{first,second}:observed_first(second,observe(first))
def increment(+delta:U32,array:Array<U32>) -> Array<U32>:
  match array:
    case ALeaf{value}:ALeaf{(value + delta : U32)}
    case ANode{left,right}:ANode{increment(delta,left),increment(delta,right)}
def update(+delta:U32,pack:Pack) -> Pack:
  match pack:
    case Pack{first,second}:Pack{increment(delta,first),increment((delta * 10 : U32),second)}
def initial(+seed:U32) -> Pack:
  Pack{ANode{ALeaf{seed},ALeaf{(seed + 1 : U32)}},ANode{ALeaf{(seed + 2 : U32)},ALeaf{(seed + 3 : U32)}}}
