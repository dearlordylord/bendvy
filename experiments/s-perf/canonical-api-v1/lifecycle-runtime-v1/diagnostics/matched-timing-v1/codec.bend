import Base
import json.bend as J

def mix(acc:U32,value:U32) -> U32:U32.add(U32.mul(acc,33),value)
def fold(values:List<&2,U32>,acc:U32) -> U32:
  match values:
    case []:acc
    case value <> rest:fold(rest,mix(acc,value))
def scalar_reverse(value:String,out:List<&2,U32>) -> List<&2,U32>:
  match value:
    case SNil{}:out
    case SCon{head,rest}:scalar_reverse(rest,Char.to_u32(head) <> out)
def natural_reverse(value:Nat,out:List<&2,U32>) -> List<&2,U32>:0 <> scalar_reverse(Nat.show(value),out)
def record(+text:String,out:List<&2,U32>) -> List<&2,U32>:scalar_reverse(text,natural_reverse(String.length(text),out))
def records(values:List<&2,J.Value>,out:List<&2,U32>) -> List<&2,U32>:
  match values:
    case []:List.reverse(&2,U32,out)
    case value <> rest:records(rest,record(J.render(value),out))
def encode(+values:List<&2,J.Value>) -> List<&2,U32>:records(values,natural_reverse(List.length(&2,J.Value,values),[]))
def join_reverse(values:List<&2,String>,suffix:String) -> String:
  match values:
    case []:suffix
    case value <> rest:join_reverse(rest,value ++ suffix)
def pieces(values:List<&2,U32>,first:Bool,out:List<&2,String>) -> String:
  match values first:
    case [],_:"[" ++ join_reverse(out,"]")
    case value <> rest,True{}:pieces(rest,False{},U32.show(value) <> out)
    case value <> rest,False{}:pieces(rest,False{},U32.show(value) <> ", " <> out)
def show(values:List<&2,U32>) -> String:pieces(values,True{},[])
