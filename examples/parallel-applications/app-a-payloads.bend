import Base

type AuditWorkshop is Data:
  AuditWorkshop{}
type QueryPack is Type:
  QueryPack{calls:Array<U32>,values:Array<U32>}
def increment(+delta:U32,values:Array<U32>) -> Array<U32>:
  match values:
    case ALeaf{value}:ALeaf{(value + delta : U32)}
    case ANode{left,right}:ANode{increment(delta,left),increment(delta,right)}
def update(value:U32,pack:QueryPack) -> QueryPack:
  match pack:
    case QueryPack{calls,values}:QueryPack{increment(1,calls),increment(value,values)}
def initial_query() -> QueryPack:
  QueryPack{ALeaf{0},ANode{ALeaf{30},ALeaf{40}}}
def initial_resource_capture() -> Array<U32>:
  ANode{ALeaf{100},ALeaf{200}}
def initial_counter() -> Array<U32>:
  ANode{ALeaf{10},ALeaf{11}}
def next_counter() -> Array<U32>:
  ANode{ALeaf{21},ALeaf{22}}
def sibling() -> Array<U32>:
  ANode{ALeaf{100},ALeaf{101}}
def replacement() -> Array<U32>:
  ANode{ALeaf{70},ALeaf{90}}
def scratch() -> Array<U32>:
  ANode{ALeaf{1},ALeaf{2}}
def project_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,xs), (right,ys):(ANode{left,right},List.append(&2,U32,xs,ys))
def project(values:Array<U32>) -> Array<U32> & List<&2,U32>:
  match values:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:project_join(project(left),project(right))
