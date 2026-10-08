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
def step(pending:List<&2,J.Token>,acc:List<&2,String>,next:List<&2,J.Token> -> List<&2,String> -> EncodeResult) -> EncodeResult:
  match pending:
    case []:EncodeComplete{reversed_chunks(acc,"")}
    case J.Visit{value} <> rest:next(List.append(&2,J.Token,J.tokens(value),rest),acc)
    case J.TraceEmit{text} <> rest:next(rest,text <> acc)
def exhausted(pending:List<&2,J.Token>,acc:List<&2,String>) -> EncodeResult:
  match pending:
    case []:EncodeComplete{reversed_chunks(acc,"")}
    case _:EncodeIncomplete{}
def walk(fuel:Nat,pending:List<&2,J.Token>,acc:List<&2,String>) -> EncodeResult:
  match fuel:
    case 0n:exhausted(pending,acc)
    case 1n+rest:step(pending,acc,pending => acc => walk(rest,pending,acc))
def encode(population:U32,value:J.Value) -> EncodeResult:
  walk(Input.serialize_budget(population),[J.Visit{value}],[])
