import Base

type Rope is Data:
  Empty{}
  Text{value:String}
  Join{left:Rope,right:Rope,work:Nat}
  ArrayLeaf{value:String}
  ArrayNode{left:Rope,right:Rope,work:Nat}
  LeafPrefix{}
  NodeOpen{}
  NodeComma{}
  NodeClose{}
def work(value:Rope) -> Nat:
  match value:
    case Empty{}:1n
    case Text{_}:1n
    case Join{_,_,count}:count
    case ArrayLeaf{_}:3n
    case ArrayNode{_,_,count}:count
    case _:1n
def text(value:String) -> Rope:Text{value}
def join(+left:Rope,+right:Rope) -> Rope:Join{left,right,Nat.add(1n,Nat.add(work(left),work(right)))}
def array_leaf(value:String) -> Rope:ArrayLeaf{value}
def array_node(+left:Rope,+right:Rope) -> Rope:ArrayNode{left,right,Nat.add(4n,Nat.add(work(left),work(right)))}
def pieces(values:List<&2,String>) -> Rope:
  match values:
    case []:Empty{}
    case head <> rest:join(text(head),pieces(rest))
def flat(value:Rope) -> String:
  match value:
    case Empty{}:""
    case Text{value}:value
    case Join{left,right,_}:flat(left) ++ flat(right)
    case ArrayLeaf{value}:"leaf:" ++ value
    case ArrayNode{left,right,_}:"node(" ++ flat(left) ++ "," ++ flat(right) ++ ")"
    case LeafPrefix{}:"leaf:"
    case NodeOpen{}:"node("
    case NodeComma{}:","
    case NodeClose{}:")"
def finished(stack:List<&2,Rope>,reversed:List<&2,String>) -> IO(Unit):
  match stack:
    case []:IO.write(String.concat(List.reverse(&2,String,reversed)))
    case _:IO.die(Unit,2,"report rope traversal count mismatch")
def write_go(fuel:Nat,stack:List<&2,Rope>,remaining:Nat,reversed:List<&2,String>) -> IO(Unit):
  match fuel:
    case 0n:finished(stack,reversed)
    case 1n+next:
      match stack:
        case []:IO.die(Unit,2,"report rope traversal ended early")
        case Empty{} <> rest:write_go(next,rest,remaining,reversed)
        case Text{value} <> rest:
          match remaining:
            case 0n:IO.bind(Unit,Unit,IO.write(String.concat(List.reverse(&2,String,reversed))),_=>write_go(next,rest,63n,[value]))
            case 1n+count:write_go(next,rest,count,value <> reversed)
        case Join{left,right,_} <> rest:write_go(next,left <> right <> rest,remaining,reversed)
        case ArrayLeaf{value} <> rest:write_go(next,LeafPrefix{} <> Text{value} <> rest,remaining,reversed)
        case ArrayNode{left,right,_} <> rest:write_go(next,NodeOpen{} <> left <> NodeComma{} <> right <> NodeClose{} <> rest,remaining,reversed)
        case LeafPrefix{} <> rest:
          match remaining:
            case 0n:IO.bind(Unit,Unit,IO.write(String.concat(List.reverse(&2,String,reversed))),_=>write_go(next,rest,63n,["leaf:"]))
            case 1n+count:write_go(next,rest,count,"leaf:" <> reversed)
        case NodeOpen{} <> rest:
          match remaining:
            case 0n:IO.bind(Unit,Unit,IO.write(String.concat(List.reverse(&2,String,reversed))),_=>write_go(next,rest,63n,["node("]))
            case 1n+count:write_go(next,rest,count,"node(" <> reversed)
        case NodeComma{} <> rest:
          match remaining:
            case 0n:IO.bind(Unit,Unit,IO.write(String.concat(List.reverse(&2,String,reversed))),_=>write_go(next,rest,63n,[","]))
            case 1n+count:write_go(next,rest,count,"," <> reversed)
        case NodeClose{} <> rest:
          match remaining:
            case 0n:IO.bind(Unit,Unit,IO.write(String.concat(List.reverse(&2,String,reversed))),_=>write_go(next,rest,63n,[")"]))
            case 1n+count:write_go(next,rest,count,")" <> reversed)

def write(+value:Rope) -> IO(Unit):write_go(work(value),[value],64n,[])
