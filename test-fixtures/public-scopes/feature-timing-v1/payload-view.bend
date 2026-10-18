import Base
import ../ordinary-v1/fixture.bend as Values

# Preserve every affine Array owner while projecting the complete shared payload.
# No physical tree constructor names enter the matched JSON transport.
def joined(right:Array<U32> & List<&2,U32>,left:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (b,other)=right
  (a,values)=left
  (ANode{a,b},List.append(&2,U32,values,other))
def flatten(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:joined(flatten(right),flatten(left))
def payload_right(first:Array<U32>,values:List<&2,U32>,seen:Array<U32> & List<&2,U32>) -> Values.Payload & List<&2,U32>:
  match seen:
    case (second,other):(Values.Payload{first,second},List.append(&2,U32,values,other))
def payload_left(second:Array<U32>,seen:Array<U32> & List<&2,U32>) -> Values.Payload & List<&2,U32>:
  match seen:
    case (first,values):payload_right(first,values,flatten(second))
def project(payload:Values.Payload) -> Values.Payload & List<&2,U32>:
  match payload:
    case Values.Payload{first,second}:payload_left(second,flatten(first))
