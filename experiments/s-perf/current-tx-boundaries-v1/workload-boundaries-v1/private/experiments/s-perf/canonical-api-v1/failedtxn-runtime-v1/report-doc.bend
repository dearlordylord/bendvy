import Base
import report-buffer.bend as Buffer
# Only immutable observed text enters Doc; count is actual Bend character length.
type Doc is Data:
  Text{value:String,count:Nat}
  PhysicalLeaf{value:String,count:Nat}
  Join{left:Doc,right:Doc,work:Nat,count:Nat}
  PhysicalNode{left:Doc,right:Doc,work:Nat,count:Nat}
  DocComma{}
  DocClose{}
def length(value:Doc) -> Nat:
  match value:
    case Text{_,count}:count
    case PhysicalLeaf{_,count}:5n+count
    case Join{_,_,_,count}:count
    case PhysicalNode{_,_,_,count}:count
    case DocComma{}:1n
    case DocClose{}:1n
def work(value:Doc) -> Nat:
  match value:
    case Text{_,_}:1n
    case PhysicalLeaf{_,_}:1n
    case Join{_,_,count,_}:count
    case PhysicalNode{_,_,count,_}:count
    case DocComma{}:1n
    case DocClose{}:1n
def text(+value:String) -> Doc:Text{value,String.length(value)}
def join(+left:Doc,+right:Doc) -> Doc:Join{left,right,1n+Nat.add(work(left),work(right)),Nat.add(length(left),length(right))}
def concat(values:List<&2,Doc>) -> Doc:
  match values:
    case []:text("")
    case head <> []:head
    case head <> rest:join(head,concat(rest))
def prefix(before:String,child:Doc) -> Doc:join(text(before),child)
def wrap(before:String,child:Doc,after:String) -> Doc:concat([text(before),child,text(after)])
def physical_node(+left:Doc,+right:Doc) -> Doc:PhysicalNode{left,right,3n+Nat.add(work(left),work(right)),7n+Nat.add(length(left),length(right))}
def audit(+value:Doc) -> Doc:join(text(Nat.show(length(value)) ++ ":"),value)
def audit_value(value:Doc) -> Doc:audit(value)
def show_rest(~T:Data,~render:T -> Doc,values:List<&2,T>) -> Doc:
  match values:
    case []:text("]")
    case head <> rest:join(text(", "),join(render(head),show_rest(~T,~render,rest)))
def show(~T:Data,~render:T -> Doc,values:List<&2,T>) -> Doc:
  match values:
    case []:text("[]")
    case head <> rest:join(text("["),join(render(head),show_rest(~T,~render,rest)))
# Exact quotient with structurally decreasing, input-derived fuel; no Nat narrowing.
type ChunkQuotient is Data:
  ChunkCount{value:Nat}
  ChunkCountExhausted{}
def full_chunks_go(fuel:Nat,count:Nat,whole:Nat,fits:Bool) -> ChunkQuotient:
  match fuel:
    case 0n:ChunkCountExhausted{}
    case 1n+fuel:
      match fits:
        case False{}:ChunkCount{whole}
        case True{}:
          +rest=Nat.sub(count,4096n)
          full_chunks_go(fuel,rest,1n+whole,Nat.is_le(4096n,rest))
def full_chunks(+count:Nat) -> ChunkQuotient:full_chunks_go(1n+count,count,0n,Nat.is_le(4096n,count))
def finished(stack:List<&2,Doc>,buffer:Buffer.Buffer) -> IO(Unit):
  match stack:
    case []:Buffer.write(buffer)
    case _ <> _:IO.die(Unit,2,"Doc work exhausted")
# The continuation runs only after actual chunk IO, never in a pure callback cycle.
def drain_once(chunks:List<&2,String>,next:List<&2,String> -> IO(Unit)) -> IO(Unit):
  match chunks:
    case []:IO.die(Unit,2,"Doc completed chunks disappeared")
    case head <> tail:IO.bind(Unit,Unit,IO.write(head),_=>next(tail))
# mode 0 visits current Doc; 1 emits comma before current right Doc;
# mode 2 emits close; 3 is finished. Only completed Doc steps select frames.
type Pending is Data:
  PendingEnd{}
  PendingRight{value:Doc,rest:Pending}
  PendingPhysicalRight{value:Doc,rest:Pending}
  PendingClose{rest:Pending}
def write_go(fuel:Nat,pending:List<&2,String>,buffer:Buffer.Buffer,mode:U32,current:Doc,rights:Pending,+original:Buffer.Buffer,+empty:List<&2,String>,+inert:Doc,+end:Pending) -> IO(Unit):
  match fuel pending buffer mode current rights:
    case 0n, [], Buffer.Buffer{_ <> _,_,_}, _, _, _:IO.die(Unit,2,"Doc work exhausted with completed chunks")
    case 0n, _ <> _, _, _, _, _:IO.die(Unit,2,"Doc work exhausted with pending chunks")
    case 0n, [], buffer, 3, _, PendingEnd{}:finished([],buffer)
    case 0n, [], _, _, _, _:IO.die(Unit,2,"Doc work exhausted")
    case 1n+rest, head <> tail, buffer, mode, current, rights:IO.bind(Unit,Unit,IO.write(head),_=>write_go(rest,tail,buffer,mode,current,rights,original,empty,inert,end))
    case 1n+rest, [], Buffer.Buffer{head <> chunks,pieces,remaining}, mode, current, rights:
      +cleared:Buffer.Buffer=Buffer.Buffer{[],pieces,remaining}
      drain_once(List.reverse(&2,String,head <> chunks),pending=>write_go(rest,pending,cleared,mode,current,rights,cleared,empty,inert,end))
    case 1n+rest, [], _, 3, _, _:IO.die(Unit,2,"Doc ended before work")
    case 1n+rest, [], _, 0, Join{left,right,_,_}, rights:write_go(rest,empty,original,0,left,PendingRight{right,rights},original,empty,inert,end)
    case 1n+rest, [], _, 0, PhysicalNode{left,right,_,_}, rights:
      +next=Buffer.known("node(",5n,original)
      write_go(rest,empty,next,0,left,PendingPhysicalRight{right,rights},next,empty,inert,end)
    case 1n+rest, [], _, 1, current, rights:
      +next=Buffer.known(",",1n,original)
      write_go(rest,empty,next,0,current,PendingClose{rights},next,empty,inert,end)
    case 1n+rest, [], _, 0, Text{value,count}, PendingRight{head,tail}:
      +next=Buffer.known(value,count,original)
      write_go(rest,empty,next,0,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, Text{value,count}, PendingPhysicalRight{head,tail}:
      +next=Buffer.known(value,count,original)
      write_go(rest,empty,next,1,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, Text{value,count}, PendingClose{tail}:
      +next=Buffer.known(value,count,original)
      write_go(rest,empty,next,2,inert,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, Text{value,count}, PendingEnd{}:
      +next=Buffer.known(value,count,original)
      write_go(rest,empty,next,3,inert,end,next,empty,inert,end)
    case 1n+rest, [], _, 0, PhysicalLeaf{value,count}, PendingRight{head,tail}:
      +next=Buffer.known(value,count,Buffer.known("leaf:",5n,original))
      write_go(rest,empty,next,0,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, PhysicalLeaf{value,count}, PendingPhysicalRight{head,tail}:
      +next=Buffer.known(value,count,Buffer.known("leaf:",5n,original))
      write_go(rest,empty,next,1,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, PhysicalLeaf{value,count}, PendingClose{tail}:
      +next=Buffer.known(value,count,Buffer.known("leaf:",5n,original))
      write_go(rest,empty,next,2,inert,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, PhysicalLeaf{value,count}, PendingEnd{}:
      +next=Buffer.known(value,count,Buffer.known("leaf:",5n,original))
      write_go(rest,empty,next,3,inert,end,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocComma{}, PendingRight{head,tail}:
      +next=Buffer.known(",",1n,original)
      write_go(rest,empty,next,0,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocComma{}, PendingPhysicalRight{head,tail}:
      +next=Buffer.known(",",1n,original)
      write_go(rest,empty,next,1,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocComma{}, PendingClose{tail}:
      +next=Buffer.known(",",1n,original)
      write_go(rest,empty,next,2,inert,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocComma{}, PendingEnd{}:
      +next=Buffer.known(",",1n,original)
      write_go(rest,empty,next,3,inert,end,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocClose{}, PendingRight{head,tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,0,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocClose{}, PendingPhysicalRight{head,tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,1,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocClose{}, PendingClose{tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,2,inert,tail,next,empty,inert,end)
    case 1n+rest, [], _, 0, DocClose{}, PendingEnd{}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,3,inert,end,next,empty,inert,end)
    case 1n+rest, [], _, 2, current, PendingRight{head,tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,0,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 2, current, PendingPhysicalRight{head,tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,1,head,tail,next,empty,inert,end)
    case 1n+rest, [], _, 2, current, PendingClose{tail}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,2,inert,tail,next,empty,inert,end)
    case 1n+rest, [], _, 2, current, PendingEnd{}:
      +next=Buffer.known(")",1n,original)
      write_go(rest,empty,next,3,inert,end,next,empty,inert,end)
    case 1n+rest, [], _, _, _, _:IO.die(Unit,2,"invalid Doc traversal mode")
def counted(+value:Doc,result:ChunkQuotient) -> IO(Unit):
  match result:
    case ChunkCount{chunks}:
      +empty:List<&2,String>=[]
      +inert:Doc=DocClose{}
      +end:Pending=PendingEnd{}
      write_go(Nat.add(work(value),chunks),empty,Buffer.empty(),0,value,end,Buffer.empty(),empty,inert,end)
    case ChunkCountExhausted{}:IO.die(Unit,2,"Doc chunk quotient exhausted")
def write(+value:Doc) -> IO(Unit):counted(value,full_chunks(length(value)))
