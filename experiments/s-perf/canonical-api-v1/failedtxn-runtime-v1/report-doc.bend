import Base
import report-buffer.bend as Buffer
# Only immutable observed text enters Doc; count is actual Bend character length.
type Doc is Data:
  Text{value:String,count:Nat}
  Join{left:Doc,right:Doc,work:Nat,count:Nat}
  PhysicalNode{left:Doc,right:Doc,work:Nat,count:Nat}
  DocComma{}
  DocClose{}
def length(value:Doc) -> Nat:
  match value:
    case Text{_,count}:count
    case Join{_,_,_,count}:count
    case PhysicalNode{_,_,_,count}:count
    case DocComma{}:1n
    case DocClose{}:1n
def work(value:Doc) -> Nat:
  match value:
    case Text{_,_}:1n
    case Join{_,_,count,_}:count
    case PhysicalNode{_,_,count,_}:count
    case DocComma{}:1n
    case DocClose{}:1n
def text(+value:String) -> Doc:Text{value,String.length(value)}
def join(+left:Doc,+right:Doc) -> Doc:Join{left,right,1n+Nat.add(work(left),work(right)),Nat.add(length(left),length(right))}
def concat(values:List<&2,Doc>) -> Doc:
  match values:
    case []:text("")
    case head <> rest:join(head,concat(rest))
def prefix(before:String,child:Doc) -> Doc:join(text(before),child)
def wrap(before:String,child:Doc,after:String) -> Doc:concat([text(before),child,text(after)])
def physical_node(+left:Doc,+right:Doc) -> Doc:PhysicalNode{left,right,3n+Nat.add(work(left),work(right)),7n+Nat.add(length(left),length(right))}
def audit(+value:Doc) -> Doc:join(text(Nat.show(length(value)) ++ ":"),value)
def audit_value(value:Doc) -> Doc:audit(value)
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
        case Text{value,count} <> tail:write_go(rest,tail,Buffer.known(value,count,buffer))
        case Join{left,right,_,_} <> tail:write_go(rest,left <> right <> tail,buffer)
        case PhysicalNode{left,right,_,_} <> tail:write_go(rest,left <> DocComma{} <> right <> DocClose{} <> tail,Buffer.known("node(",5n,buffer))
        case DocComma{} <> tail:write_go(rest,tail,Buffer.known(",",1n,buffer))
        case DocClose{} <> tail:write_go(rest,tail,Buffer.known(")",1n,buffer))
def write(+value:Doc) -> IO(Unit):write_go(work(value),[value],Buffer.empty())
