import Base
import ../../../method/json.bend as J

type Task is Data:
  ValueTask{value:J.Value}
  ValuesTask{values:List<&2,J.Value>}
  FieldsTask{fields:List<&2,J.Field>}
  StringTask{value:String}
  CharsTask{value:String}
  NaturalTask{value:Nat}
type State is Data:
  State{tasks:List<&2,Task>,token:U32}
type Outcome is Data:
  Complete{token:U32}
  Exhausted{}
def radix() -> Nat:Nat.mul(65536n,65536n)
def mix(acc:U32,value:U32) -> U32:U32.add(U32.mul(acc,33),value)
def boolean(value:Bool) -> U32:
  match value:
    case False{}:0
    case True{}:1
def walk_value(rest:List<&2,Task>,acc:U32,value:J.Value) -> State:
  match value:
    case J.Null{}:State{rest,mix(acc,0)}
    case J.Boolean{flag}:State{rest,mix(mix(acc,1),boolean(flag))}
    case J.Number{number}:State{NaturalTask{number} <> rest,mix(acc,2)}
    case J.Text{text}:State{StringTask{text} <> rest,mix(acc,3)}
    case J.Array{+values,_}:State{NaturalTask{List.length(&2,J.Value,values)} <> ValuesTask{values} <> rest,mix(acc,4)}
    case J.Object{+fields,_}:State{NaturalTask{List.length(&2,J.Field,fields)} <> FieldsTask{fields} <> rest,mix(acc,5)}
def walk_values(rest:List<&2,Task>,acc:U32,values:List<&2,J.Value>) -> State:
  match values:
    case []:State{rest,acc}
    case head <> tail:State{ValueTask{head} <> ValuesTask{tail} <> rest,acc}
def field(rest:List<&2,Task>,acc:U32,value:J.Field) -> State:
  match value:
    case J.Field{key,value}:State{StringTask{key} <> ValueTask{value} <> rest,acc}
def walk_fields(rest:List<&2,Task>,acc:U32,fields:List<&2,J.Field>) -> State:
  match fields:
    case []:State{rest,acc}
    case head <> tail:field(FieldsTask{tail} <> rest,acc,head)
def chars(rest:List<&2,Task>,acc:U32,value:String) -> State:
  match value:
    case SNil{}:State{rest,acc}
    case SCon{head,tail}:State{CharsTask{tail} <> rest,mix(acc,Char.to_u32(head))}
def natural(rest:List<&2,Task>,acc:U32,result:Nat & Nat) -> State:
  match result:
    case (0n,low):State{rest,mix(mix(acc,U32.from_nat(low)),4294967295)}
    case (high,low):State{NaturalTask{high} <> rest,mix(acc,U32.from_nat(low))}
def task(rest:List<&2,Task>,acc:U32,value:Task) -> State:
  match value:
    case ValueTask{value}:walk_value(rest,acc,value)
    case ValuesTask{items}:walk_values(rest,acc,items)
    case FieldsTask{items}:walk_fields(rest,acc,items)
    case StringTask{+text}:State{NaturalTask{String.length(text)} <> CharsTask{text} <> rest,acc}
    case CharsTask{text}:chars(rest,acc,text)
    case NaturalTask{number}:natural(rest,acc,Nat.divmod(number,radix()))
def step(state:State) -> State:
  match state:
    case State{[],acc}:State{[],acc}
    case State{head <> rest,acc}:task(rest,acc,head)
def run(fuel:Nat,state:State) -> Outcome:
  match fuel state:
    case _,State{[],acc}:Complete{acc}
    case 0n,_:Exhausted{}
    case 1n+rest,State{head <> tasks,acc}:run(rest,task(tasks,acc,head))
# Cache counts are renderer work budgets, never semantic array/object lengths.
# Root scalars avoid J.work(Number), which formats a Nat only to count digits.
def root_work(value:J.Value) -> Nat:
  match value:
    case J.Null{}:1n
    case J.Boolean{_}:1n
    case J.Number{number}:3n+Nat.div(number,radix())
    case J.Text{text}:2n+String.length(text)
    case J.Array{_,count}:count
    case J.Object{_,count}:count
def budget(values:List<&2,J.Value>,acc:Nat) -> Nat:
  match values:
    case []:Nat.mul(2n,acc)
    case head <> rest:budget(rest,1n+Nat.add(root_work(head),acc))
def force(+values:List<&2,J.Value>) -> Outcome:run(budget(values,2n),State{[ValueTask{J.Array{values,0n}}],0})
