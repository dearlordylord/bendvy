import Base
def snapshot_done(-A:Data,+head:A,pair:List<A> & List<&2,A>) -> List<A> & List<&2,A>:
  match pair:
    case (tail,view): (head <> tail,head <> view)
def snapshot(-A:Data,values:List<A>) -> List<A> & List<&2,A>:
  match values:
    case Nil{}: ([],[])
    case Con{head,tail}: snapshot_done(A,head,snapshot(A,tail))
def sum(values:List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head,tail}: U32.add(head,sum(tail))
def observed(old:List<&2,U32>,a:U32,b:U32,pair:List<U32> & List<&2,U32>) -> IO(Unit):
  match pair:
    case (_,fresh): IO.print(U32.show(a) ++ ":" ++ U32.show(b) ++ ":" ++ U32.show(sum(old)) ++ ":" ++ U32.show(sum(fresh)))
def repeated(owner:List<U32>,retained:List<&2,U32>,a:U32,b:U32) -> IO(Unit):
  observed(retained,a,b,snapshot(U32,owner))
def completed(pair:List<U32> & List<&2,U32>) -> IO(Unit):
  match pair:
    case (owner,+view): repeated(owner,view,sum(view),sum(view))
def main() -> IO(Unit):
  completed(snapshot(U32,[1,2,3]))
