import Base
import ../../../trace-value.bend as J
import ../../input.bend as Input

type EncodeResult is Data:
  EncodeComplete{text:String}
  EncodeIncomplete{}
def reversed_chunks(chunks:List<&2,String>,acc:String) -> String:
  match chunks:
    case []:acc
    case head <> tail:reversed_chunks(tail,head ++ acc)
def exhausted(pending:List<&2,J.Token>,acc:List<&2,String>) -> EncodeResult:
  match pending:
    case []:EncodeComplete{reversed_chunks(acc,"")}
    case _:EncodeIncomplete{}
def walk(fuel:Nat,pending:List<&2,J.Token>,acc:List<&2,String>) -> EncodeResult:
  match fuel pending:
    case _ []:EncodeComplete{reversed_chunks(acc,"")}
    case 0n _:EncodeIncomplete{}
    case 1n+rest J.Visit{value} <> tail:walk(rest,List.append(&2,J.Token,J.tokens(value),tail),acc)
    case 1n+rest J.TraceEmit{text} <> tail:walk(rest,tail,text <> acc)
def encode(population:U32,value:J.Value) -> EncodeResult:
  walk(Input.serialize_budget(population),[J.Visit{value}],[])
