import Base
# Project each owned leaf exactly once; reversed pieces contain text only.
def join_rev(pieces:List<&2,String>,suffix:String) -> String:
  match pieces:
    case []:suffix
    case head <> rest:join_rev(rest,head ++ suffix)
def leaf(~T:Type,acc:List<&2,String>,observed:T & String) -> Array<T> & List<&2,String>:
  match observed:
    case (value,text):(ALeaf{value},text <> "leaf:" <> acc)
def right(~T:Type,left:Array<T>,observed:Array<T> & List<&2,String>) -> Array<T> & List<&2,String>:
  match observed:
    case (right,acc):(ANode{left,right},")" <> acc)
def left(~T:Type,next:List<&2,String> -> Array<T> & List<&2,String>,observed:Array<T> & List<&2,String>) -> Array<T> & List<&2,String>:
  match observed:
    case (owner,acc):right(~T,owner,next("," <> acc))
def accumulate(~T:Type,~project:T -> T & String,value:Array<T>,acc:List<&2,String>) -> Array<T> & List<&2,String>:
  match value:
    case ALeaf{value}:leaf(~T,acc,project(value))
    case ANode{a,b}:left(~T,acc=>accumulate(~T,~project,b,acc),accumulate(~T,~project,a,"node(" <> acc))
def finished(~T:Type,observed:Array<T> & List<&2,String>) -> Array<T> & String:
  match observed:
    case (owner,acc):(owner,join_rev(acc,""))
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:finished(~T,accumulate(~T,~project,value,[]))
