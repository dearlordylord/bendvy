import Base
# Library-owned inverse records. No arbitrary caller inverse or destructive callback.
# Release rows retain the displaced owners; callers decide their subsequent use.
type Record<P:Type> is Type:
  Replaced{value:Array<P>}
  Swapped{index:U32,value:P}
def undone(~P:Type,index:U32,result:Array<P> & P) -> Array<P> & Record<P>:
  match result:
    case (array,replacement):(array,Swapped{index,replacement})
def undo(~P:Type,record:Record<P>,array:Array<P>) -> Array<P> & Record<P>:
  match record:
    case Replaced{old}:(old,Replaced{array})
    case Swapped{+index,old}:undone(~P,index,Array.swap(P,array,index,old))
