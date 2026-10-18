import Base
import json.bend as J
import method.bend as M

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
def encode(value:M.State) -> List<&2,U32>:
  match value:
    case M.State{_,+values}:records(values,natural_reverse(List.length(&2,J.Value,values),[]))
def write_chunk(reversed:List<&2,String>) -> IO(Unit):IO.write(String.concat(List.reverse(&2,String,reversed)))
def write_piece(value:U32,first:Bool) -> String:
  match first:
    case True{}:U32.show(value)
    case False{}:", " ++ U32.show(value)
def write_go(values:List<&2,U32>,first:Bool,remaining:Nat,reversed:List<&2,String>) -> IO(Unit):
  match values:
    case []:IO.bind(Unit,Unit,write_chunk(reversed),_=>IO.write("]\n"))
    case value <> rest:
      match remaining:
        case 0n:IO.bind(Unit,Unit,write_chunk(reversed),_=>write_go(rest,False{},63n,[write_piece(value,first)]))
        case 1n+next:write_go(rest,False{},next,write_piece(value,first) <> reversed)
def write(prefix:String,values:List<&2,U32>) -> IO(Unit):IO.bind(Unit,Unit,IO.write(prefix ++ "["),_=>write_go(values,True{},64n,[]))
