import Base
# Built-in transparent payloads need no caller-authored display adapter.
def u32(value:U32) -> U32 & String:
  +value=value
  (value,U32.show(value))
def bool(value:Bool) -> Bool & String:
  +value=value
  (value,Bool.show(value))
def leaf(result:U32 & String) -> Array<U32> & String:
  match result:
    case (value,text):(ALeaf{value},"leaf:" ++ text)
def node(left:Array<U32> & String,right:Array<U32> & String) -> Array<U32> & String:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},"node(" ++ a ++ "," ++ b ++ ")")
def array(value:Array<U32>) -> Array<U32> & String:
  match value:
    case ALeaf{value}:leaf(u32(value))
    case ANode{left,right}:node(array(left),array(right))
