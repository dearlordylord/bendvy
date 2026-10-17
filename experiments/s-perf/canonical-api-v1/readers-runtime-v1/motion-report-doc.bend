import Base
import motion-doc-buffer.bend as Buffer

type Doc is Data:
  Empty{}
  Text{value:String}
  Join{left:Doc,right:Doc,work:Nat}
  PhysicalNode{left:Doc,right:Doc,work:Nat}
  Prefix{prefix:String,child:Doc,work:Nat}
  Wrap{prefix:String,child:Doc,suffix:String,work:Nat}
  DocComma{}
  DocClose{}
  ScalarLeaf{value:String}
  NoneLeaf{}
  WrappedLeaf{child:Doc,work:Nat}
def work(value:Doc) -> Nat:
  match value:
    case Empty{}:1n
    case Text{_}:1n
    case Join{_,_,count}:count
    case PhysicalNode{_,_,count}:count
    case Prefix{_,_,count}:count
    case Wrap{_,_,_,count}:count
    case DocComma{}:1n
    case DocClose{}:1n
    case ScalarLeaf{_}:1n
    case NoneLeaf{}:1n
    case WrappedLeaf{_,count}:count
def text(value:String) -> Doc:Text{value}
def join(+left:Doc,+right:Doc) -> Doc:Join{left,right,1n+Nat.add(work(left),work(right))}
def physical_node(+left:Doc,+right:Doc) -> Doc:PhysicalNode{left,right,3n+Nat.add(work(left),work(right))}
def prefix(value:String,+child:Doc) -> Doc:Prefix{value,child,1n+work(child)}
def wrap(before:String,+child:Doc,after:String) -> Doc:Wrap{before,child,after,2n+work(child)}
def wrapped_leaf(+child:Doc) -> Doc:WrappedLeaf{child,2n+work(child)}
def concat(values:List<&2,Doc>) -> Doc:
  match values:
    case []:Empty{}
    case head <> rest:join(head,concat(rest))
def flatten(value:Doc) -> String:
  match value:
    case Empty{}:""
    case Text{value}:value
    case Join{left,right,_}:String.append(flatten(left),flatten(right))
    case PhysicalNode{left,right,_}:"node(" ++ flatten(left) ++ "," ++ flatten(right) ++ ")"
    case Prefix{prefix,child,_}:String.append(prefix,flatten(child))
    case Wrap{prefix,child,suffix,_}:prefix ++ flatten(child) ++ suffix
    case DocComma{}:","
    case DocClose{}:")"
    case ScalarLeaf{value}:"leaf:" ++ value
    case NoneLeaf{}:"leaf:none"
    case WrappedLeaf{child,_}:"leaf:some(" ++ flatten(child) ++ ")"
def show_rest(~T:Data,~render:T -> Doc,values:List<&2,T>) -> Doc:
  match values:
    case []:text("]")
    case head <> rest:concat([text(", "),render(head),show_rest(~T,~render,rest)])
def show(~T:Data,~render:T -> Doc,values:List<&2,T>) -> Doc:
  match values:
    case []:text("[]")
    case head <> rest:concat([text("["),render(head),show_rest(~T,~render,rest)])
def finished(stack:List<&2,Doc>,buffer:Buffer.Buffer) -> IO(Unit):
  match stack:
    case []:Buffer.write(buffer)
    case _ <> _:IO.die(Unit,2,"Doc work exhausted")
def write_go(fuel:Nat,stack:List<&2,Doc>,buffer:Buffer.Buffer) -> IO(Unit):
  match fuel:
    case 0n:finished(stack,buffer)
    case 1n+rest:
      match stack:
        case []:IO.die(Unit,2,"Doc ended before work")
        case Empty{} <> tail:write_go(rest,tail,buffer)
        case Text{value} <> tail:write_go(rest,tail,Buffer.text(value,buffer))
        case Join{left,right,_} <> tail:write_go(rest,left <> right <> tail,buffer)
        case PhysicalNode{left,right,_} <> tail:write_go(rest,left <> DocComma{} <> right <> DocClose{} <> tail,Buffer.text("node(",buffer))
        case Prefix{prefix,child,_} <> tail:write_go(rest,child <> tail,Buffer.text(prefix,buffer))
        case Wrap{prefix,child,suffix,_} <> tail:write_go(rest,child <> Text{suffix} <> tail,Buffer.text(prefix,buffer))
        case DocComma{} <> tail:write_go(rest,tail,Buffer.text(",",buffer))
        case DocClose{} <> tail:write_go(rest,tail,Buffer.text(")",buffer))
        case ScalarLeaf{value} <> tail:write_go(rest,tail,Buffer.text(value,Buffer.text("leaf:",buffer)))
        case NoneLeaf{} <> tail:write_go(rest,tail,Buffer.text("leaf:none",buffer))
        case WrappedLeaf{child,_} <> tail:write_go(rest,child <> DocClose{} <> tail,Buffer.text("leaf:some(",buffer))
def write(+value:Doc) -> IO(Unit):write_go(work(value),[value],Buffer.empty())
