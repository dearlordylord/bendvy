import Base

type Value is Data:
  Null{}
  Boolean{value:Bool}
  Number{value:Nat}
  Text{value:String}
  Array{values:List<&2,Value>,count:Nat}
  Object{fields:List<&2,Field>,count:Nat}
type Field is Data:
  Field{key:String,value:Value}
type Task is Data:
  ValueTask{value:Value}
  ArrayTask{values:List<&2,Value>,first:Bool}
  ObjectTask{fields:List<&2,Field>,first:Bool}
  QuoteTask{value:String}
  RawTask{value:String}
  LiteralTask{value:String}
def text_work(value:String) -> Nat:2n+String.length(value)
def work(value:Value) -> Nat:
  match value:
    case Null{}:1n
    case Boolean{_}:1n
    case Number{value}:2n+String.length(Nat.show(value))
    case Text{value}:text_work(value)
    case Array{_,count}:count
    case Object{_,count}:count
def values_work(values:List<&2,Value>,count:Nat) -> Nat:
  match values:
    case []:count
    case head <> rest:values_work(rest,1n+Nat.add(work(head),count))
def field_work(value:Field) -> Nat:
  match value:
    case Field{key,value}:2n+Nat.add(text_work(key),work(value))
def fields_work(values:List<&2,Field>,count:Nat) -> Nat:
  match values:
    case []:count
    case head <> rest:fields_work(rest,Nat.add(field_work(head),count))
def array(+values:List<&2,Value>) -> Value:Array{values,1n+values_work(values,1n)}
def object(+fields:List<&2,Field>) -> Value:Object{fields,1n+fields_work(fields,1n)}
def bool_text(value:Bool) -> String:
  match value:
    case False{}:"false"
    case True{}:"true"
def hex(value:U32) -> String:
  match value:
    case 0:"0"
    case 1:"1"
    case 2:"2"
    case 3:"3"
    case 4:"4"
    case 5:"5"
    case 6:"6"
    case 7:"7"
    case 8:"8"
    case 9:"9"
    case 10:"a"
    case 11:"b"
    case 12:"c"
    case 13:"d"
    case 14:"e"
    case _:"f"
def ordinary_char(+value:Char,small:Bool) -> String:
  match small:
    case True{}:"\\u00" ++ hex(U32.shr(U32.shr(U32.shr(U32.shr(Char.to_u32(value)))))) ++ hex(U32.and(Char.to_u32(value),15))
    case False{}:SCon{value,SNil{}}
def escaped_code(+value:Char,code:U32) -> String:
  match code:
    case 34:"\\\""
    case 92:"\\\\"
    case 8:"\\b"
    case 12:"\\f"
    case 10:"\\n"
    case 13:"\\r"
    case 9:"\\t"
    case _:ordinary_char(value,U32.is_lt(Char.to_u32(value),32))
def escaped(+value:Char) -> String:escaped_code(value,Char.to_u32(value))
def join_rev(values:List<&2,String>,suffix:String) -> String:
  match values:
    case []:suffix
    case head <> rest:join_rev(rest,head ++ suffix)
type State is Data:
  State{tasks:List<&2,Task>,pieces:List<&2,String>}
def finish(tasks:List<&2,Task>,pieces:List<&2,String>) -> String:
  match tasks:
    case []:join_rev(pieces,"")
    case _:"invalid JSON fuel"
def done(value:State) -> String:
  match value:
    case State{tasks,pieces}:finish(tasks,pieces)
def array_case(rest:List<&2,Task>,pieces:List<&2,String>,first:Bool,values:List<&2,Value>) -> State:
  match first values:
    case _,[]:State{rest,"]" <> pieces}
    case True{},head <> tail:State{ValueTask{head} <> ArrayTask{tail,False{}} <> rest,pieces}
    case False{},head <> tail:State{ValueTask{head} <> ArrayTask{tail,False{}} <> rest,"," <> pieces}
def object_field(rest:List<&2,Task>,pieces:List<&2,String>,fields:List<&2,Field>,value:Field) -> State:
  match value:
    case Field{key,value}:State{ValueTask{Text{key}} <> LiteralTask{":"} <> ValueTask{value} <> ObjectTask{fields,False{}} <> rest,pieces}
def object_case(rest:List<&2,Task>,pieces:List<&2,String>,first:Bool,fields:List<&2,Field>) -> State:
  match first fields:
    case _,[]:State{rest,"}" <> pieces}
    case True{},head <> tail:object_field(rest,pieces,tail,head)
    case False{},head <> tail:object_field(rest,"," <> pieces,tail,head)
def quoted(rest:List<&2,Task>,pieces:List<&2,String>,value:String) -> State:
  match value:
    case SNil{}:State{rest,"\"" <> pieces}
    case SCon{head,tail}:State{QuoteTask{tail} <> rest,escaped(head) <> pieces}
def raw_chars(rest:List<&2,Task>,pieces:List<&2,String>,value:String) -> State:
  match value:
    case SNil{}:State{rest,pieces}
    case SCon{head,tail}:State{RawTask{tail} <> rest,SCon{head,SNil{}} <> pieces}
def value_case(rest:List<&2,Task>,pieces:List<&2,String>,value:Value) -> State:
  match value:
    case Null{}:State{rest,"null" <> pieces}
    case Boolean{value}:State{rest,bool_text(value) <> pieces}
    case Number{value}:State{RawTask{Nat.show(value)} <> rest,pieces}
    case Text{value}:State{QuoteTask{value} <> rest,"\"" <> pieces}
    case Array{values,_}:State{ArrayTask{values,True{}} <> rest,"[" <> pieces}
    case Object{fields,_}:State{ObjectTask{fields,True{}} <> rest,"{" <> pieces}
def task_case(rest:List<&2,Task>,pieces:List<&2,String>,value:Task) -> State:
  match value:
    case ValueTask{value}:value_case(rest,pieces,value)
    case ArrayTask{values,first}:array_case(rest,pieces,first,values)
    case ObjectTask{fields,first}:object_case(rest,pieces,first,fields)
    case QuoteTask{value}:quoted(rest,pieces,value)
    case RawTask{value}:raw_chars(rest,pieces,value)
    case LiteralTask{value}:State{rest,value <> pieces}
def step(value:State) -> State:
  match value:
    case State{[],pieces}:State{[],pieces}
    case State{head <> rest,pieces}:task_case(rest,pieces,head)
def render_go(fuel:Nat,value:State) -> String:
  match fuel:
    case 0n:done(value)
    case 1n+fuel:render_go(fuel,step(value))
def render(+value:Value) -> String:render_go(work(value),State{[ValueTask{value}],[]})
