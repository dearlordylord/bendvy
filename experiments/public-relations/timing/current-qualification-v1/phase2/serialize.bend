import Base
import ../trace-value.bend as J
import input.bend as Input

type EncodeResult is Data:
  EncodeComplete{text:String}
  EncodeIncomplete{}
def step(pending:List<&2,J.Token>,acc:List<&2,Char>,next:List<&2,J.Token> -> List<&2,Char> -> EncodeResult) -> EncodeResult:
  match pending:
    case []:EncodeComplete{J.reversed_string(acc,"")}
    case J.Visit{value} <> rest:next(List.append(&2,J.Token,J.tokens(value),rest),acc)
    case J.TraceEmit{text} <> rest:next(rest,J.chars(text,acc))
def exhausted(pending:List<&2,J.Token>,acc:List<&2,Char>) -> EncodeResult:
  match pending:
    case []:EncodeComplete{J.reversed_string(acc,"")}
    case _:EncodeIncomplete{}
def walk(fuel:Nat,pending:List<&2,J.Token>,acc:List<&2,Char>) -> EncodeResult:
  match fuel:
    case 0n:exhausted(pending,acc)
    case 1n+rest:step(pending,acc,pending => acc => walk(rest,pending,acc))
def encode(population:U32,value:J.Value) -> EncodeResult:
  walk(Input.serialize_budget(population),[J.Visit{value}],[])
