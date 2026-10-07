import Base
# Closed immutable public fixture value tree. No World/Array owner escapes into it.
# Text values in this fixture are authored ASCII labels without JSON escapes.
type Value is Data:
  Null{}
  Number{value:U32}
  Text{value:String}
  Truth{value:Bool}
  Items{values:List<&2,Value>}
  Object{fields:List<&2,Field>}
type Field is Data:
  Field{key:String,value:Value}
def numbers(values:List<&2,U32>) -> List<&2,Value>:
  match values:
    case []:[]
    case value <> rest:Number{value} <> numbers(rest)
def maybe_number(value:Maybe<&2,U32>) -> Value:
  match value:
    case None{}:Null{}
    case Some{n}:Number{n}
type Token is Data:
  Visit{value:Value}
  TraceEmit{text:String}
def array_tail(values:List<&2,Value>) -> List<&2,Token>:
  match values:
    case []:[]
    case value <> rest:TraceEmit{","} <> Visit{value} <> array_tail(rest)
def array_tokens(values:List<&2,Value>) -> List<&2,Token>:
  match values:
    case []:[]
    case value <> rest:Visit{value} <> array_tail(rest)
def field_tokens(field:Field,rest:List<&2,Token>) -> List<&2,Token>:
  match field:
    case Field{key,value}:TraceEmit{"\"" ++ key ++ "\":"} <> Visit{value} <> rest
def object_tail(fields:List<&2,Field>) -> List<&2,Token>:
  match fields:
    case []:[]
    case field <> rest:TraceEmit{","} <> field_tokens(field,object_tail(rest))
def object_tokens(fields:List<&2,Field>) -> List<&2,Token>:
  match fields:
    case []:[]
    case field <> rest:field_tokens(field,object_tail(rest))
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def tokens(value:Value) -> List<&2,Token>:
  match value:
    case Null{}:[TraceEmit{"null"}]
    case Number{value}:[TraceEmit{U32.show(value)}]
    case Text{value}:[TraceEmit{"\"" ++ value ++ "\""}]
    case Truth{value}:[TraceEmit{boolean(value)}]
    case Items{values}:TraceEmit{"["} <> List.append(&2,Token,array_tokens(values),[TraceEmit{"]"}])
    case Object{fields}:TraceEmit{"{"} <> List.append(&2,Token,object_tokens(fields),[TraceEmit{"}"}])
def chars(text:String,acc:List<&2,Char>) -> List<&2,Char>:
  match text:
    case SNil{}:acc
    case SCon{head,tail}:chars(tail,head <> acc)
def reversed_string(chars:List<&2,Char>,acc:String) -> String:
  match chars:
    case []:acc
    case head <> tail:reversed_string(tail,SCon{head,acc})
# Host serializer has an explicit finite work budget; exhaustion fails the oracle.
def serialize_step(pending:List<&2,Token>,acc:List<&2,Char>,next:List<&2,Token> -> List<&2,Char> -> String) -> String:
  match pending:
    case []:reversed_string(acc,"")
    case Visit{value} <> rest:next(List.append(&2,Token,tokens(value),rest),acc)
    case TraceEmit{text} <> rest:next(rest,chars(text,acc))
def serialize(fuel:Nat,pending:List<&2,Token>,acc:List<&2,Char>) -> String:
  match fuel:
    case 0n:"SERIALIZATION_INCOMPLETE"
    case 1n+rest:serialize_step(pending,acc,pending => acc => serialize(rest,pending,acc))
def encode(value:Value) -> String:
  serialize(U32.to_nat(100000),[Visit{value}],[])
