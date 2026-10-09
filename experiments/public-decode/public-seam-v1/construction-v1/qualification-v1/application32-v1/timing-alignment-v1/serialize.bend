import Base
import ./public.bend as Public
import ./owner.bend as Owner
import ./application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-size.bend as Size
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

# Closed selected32 benchmark serializer; ASCII labels and selected Raw shapes.
# Unsupported variants are marked and must fail the frozen complete oracle.
def record(tag:String,fields:List<&2,J.Field>) -> J.Value:J.Object{J.Field{"$",J.Text{tag}} <> fields}
def bools(values:List<&2,Bool>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case item <> rest:J.Truth{item} <> bools(rest)
type RawTask is Data:VisitRaw{value:D.Raw} Ready{value:J.Value} ArrayEnd{count:Nat} ObjectEnd{count:Nat} FieldEnd{name:String}
def visits(values:List<&2,D.Raw>) -> List<&2,RawTask>:
  match values:
    case []:[]
    case value <> rest:VisitRaw{value} <> visits(rest)
def field_visits(fields:List<&2,D.Field>) -> List<&2,RawTask>:
  match fields:
    case []:[]
    case D.Field{name,value} <> rest:VisitRaw{value} <> FieldEnd{name} <> field_visits(rest)
def length(~T:Data,values:List<&2,T>) -> Nat:
  match values:
    case []:0n
    case _ <> rest:Succ{length(~T,rest)}
def expand(value:D.Raw) -> List<&2,RawTask>:
  match value:
    case D.Missing{}:[Ready{record("Missing",[])}]
    case D.Null{}:[Ready{record("Null",[])}]
    case D.Number{n}:[Ready{record("Number",[J.Field{"value",J.Number{n}}])}]
    case D.Text{text}:[Ready{record("Text",[J.Field{"value",J.Text{text}}])}]
    case D.Boolean{value}:[Ready{record("Boolean",[J.Field{"value",J.Truth{value}}])}]
    case D.Array{+items}:List.append(&2,RawTask,visits(items),[ArrayEnd{length(~D.Raw,items)}])
    case D.Object{+fields}:List.append(&2,RawTask,field_visits(fields),[ObjectEnd{length(~D.Field,fields)}])
    case _:[Ready{record("UnsupportedRaw",[])}]
def collect(n:Nat,stack:List<&2,J.Value>,acc:List<&2,J.Value>) -> List<&2,J.Value> & List<&2,J.Value>:
  match n:
    case Zero{}:(stack,acc)
    case Succ{rest}:
      match stack:
        case value <> stack:collect(rest,stack,value <> acc)
        case []:([],[record("UnsupportedRawStack",[])])
def grouped(key:String,field:String,collected:List<&2,J.Value> & List<&2,J.Value>) -> List<&2,J.Value>:
  match collected:
    case (stack,values):record(key,[J.Field{field,J.Items{values}}]) <> stack
def field(name:String,stack:List<&2,J.Value>) -> List<&2,J.Value>:
  match stack:
    case value <> rest:record("Field",[J.Field{"name",J.Text{name}},J.Field{"value",value}]) <> rest
    case []:[record("UnsupportedRawStack",[])]
def raw_step(todo:List<&2,RawTask>,stack:List<&2,J.Value>,next:List<&2,RawTask> -> List<&2,J.Value> -> J.Value) -> J.Value:
  match todo:
    case []:
      match stack:
        case []:record("UnsupportedRawStack",[])
        case value <> rest:
          match rest:
            case []:value
            case _:record("UnsupportedRawStack",[])
    case VisitRaw{value} <> rest:next(List.append(&2,RawTask,expand(value),rest),stack)
    case Ready{value} <> rest:next(rest,value <> stack)
    case ArrayEnd{n} <> rest:next(rest,grouped("Array","items",collect(n,stack,[])))
    case ObjectEnd{n} <> rest:next(rest,grouped("Object","fields",collect(n,stack,[])))
    case FieldEnd{name} <> rest:next(rest,field(name,stack))
def raw_walk(fuel:Nat,todo:List<&2,RawTask>,stack:List<&2,J.Value>) -> J.Value:
  match fuel:
    case Zero{}:record("UnsupportedRawBudget",[])
    case Succ{rest}:raw_step(todo,stack,todo => stack => raw_walk(rest,todo,stack))
def raw(+value:D.Raw) -> J.Value:raw_walk(Nat.add(1n,Nat.mul(4n,Size.raw_size(value))),[VisitRaw{value}],[])
def owner(value:Owner.View) -> J.Value:
  match value:
    case Owner.View{value,original,words,flags}:record("View",[J.Field{"raw",raw(value)},J.Field{"original",raw(original)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{bools(flags)}}])
def input(value:Owner.InputView) -> J.Value:
  match value:
    case Owner.InputView{value,words,flags}:record("InputView",[J.Field{"raw",raw(value)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{bools(flags)}}])
def maybe_owner(value:Maybe<&2,Owner.View>) -> J.Value:
  match value:
    case None{}:record("None",[])
    case Some{value}:record("Some",[J.Field{"value",owner(value)}])
def maybe_input(value:Maybe<&2,Owner.InputView>) -> J.Value:
  match value:
    case None{}:record("None",[])
    case Some{value}:record("Some",[J.Field{"value",input(value)}])
def maybe_number(value:Maybe<&2,U32>) -> J.Value:
  match value:
    case None{}:record("None",[])
    case Some{value}:record("Some",[J.Field{"value",J.Number{value}}])
def payload(value:App.QueuedPayload) -> J.Value:
  match value:
    case App.ComponentPayload{value}:record("ComponentPayload",[J.Field{"owner",owner(value)}])
    case App.MarkerPayload{n}:record("MarkerPayload",[J.Field{"value",J.Number{n}}])
def pending(values:List<&2,Public.Pending>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Public.Pending{kind,system,target,value} <> rest:record("Pending",[J.Field{"kind",J.Text{kind}},J.Field{"system",J.Text{system}},J.Field{"target",J.Number{target}},J.Field{"payload",payload(value)}]) <> pending(rest)
def entities(values:List<&2,Public.Entity>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Public.Entity{id,value,marker} <> rest:record("Entity",[J.Field{"id",J.Number{id}},J.Field{"value",maybe_owner(value)},J.Field{"marker",maybe_number(marker)}]) <> entities(rest)
def state(value:Public.State) -> J.Value:
  match value:
    case Public.State{rows,resource,commands,count,consistent}:record("State",[J.Field{"entities",J.Items{entities(rows)}},J.Field{"resource",owner(resource)},J.Field{"pending",J.Items{pending(commands)}},J.Field{"logicalPendingCount",J.Number{count}},J.Field{"receiptLoweringMatches",J.Truth{consistent}}])
    case _:record("UnsupportedState",[])
def error(value:D.Error) -> J.Value:
  match value:
    case D.Invalid{path,expected,actual}:record("Invalid",[J.Field{"path",J.Text{path}},J.Field{"expected",J.Text{expected}},J.Field{"actual",raw(actual)}])
    case D.FuelExhausted{path}:record("FuelExhausted",[J.Field{"path",J.Text{path}}])
def world_error(value:W.WorldError) -> J.Value:
  match value:
    case W.MissingEntity{}:record("MissingEntity",[])
    case W.CapacityExceeded{}:record("CapacityExceeded",[])
    case W.NamespaceExhausted{}:record("NamespaceExhausted",[])
    case W.SystemIdExhausted{}:record("SystemIdExhausted",[])
def request_error(value:Request.Error) -> J.Value:
  match value:
    case Request.Validation{e}:record("Validation",[J.Field{"error",error(e)}])
    case Request.Entity{e}:record("Entity",[J.Field{"error",world_error(e)}])
def mode(value:App.Mode) -> J.Value:
  match value:
    case App.Spawn{}:record("Spawn",[])
    case App.Insert{}:record("Insert",[])
    case App.ResourceWrite{}:record("ResourceWrite",[])
def checked(value:Public.Checked) -> J.Value:
  match value:
    case Public.Accepted{target,spawned,value}:record("Accepted",[J.Field{"target",maybe_number(target)},J.Field{"spawned",J.Truth{spawned}},J.Field{"canonical",raw(value)}])
    case Public.Refused{value,e}:record("Refused",[J.Field{"input",maybe_input(value)},J.Field{"error",request_error(e)}])
    case Public.SystemFailed{_}:record("SystemFailed",[J.Field{"error",record("Unit",[])}])
    case Public.InvocationRefused{value,operation,namespace,target}:record("InvocationRefused",[J.Field{"input",input(value)},J.Field{"operation",mode(operation)},J.Field{"namespace",J.Number{namespace}},J.Field{"target",J.Number{target}}])
def view(value:Public.View) -> J.Value:
  match value:
    case Public.View{original,before,committed,barrier,result}:record("View",[J.Field{"original",input(original)},J.Field{"before",state(before)},J.Field{"committed",state(committed)},J.Field{"barrier",state(barrier)},J.Field{"checked",checked(result)}])
    case _:record("SetupRefused",[])
# Work-derived serializer budget: every Visit and emitted token is covered.
def tree_size(value:J.Value) -> Nat:
  match value:
    case J.Items{[]} :1n
    case J.Items{head <> rest}:Nat.add(tree_size(head),tree_size(J.Items{rest}))
    case J.Object{[]}:1n
    case J.Object{J.Field{_,child} <> rest}:Nat.add(tree_size(child),tree_size(J.Object{rest}))
    case _:1n
# Eight traversal steps per structural tree unit dominate Visit, punctuation,
# field-name and scalar tokens; this scales with the actual complete observation.
def budget(value:J.Value) -> Nat:Nat.add(1n,Nat.mul(8n,tree_size(value)))
type Encoded is Data:Complete{text:String} Incomplete{}
def exhausted(pending:List<&2,J.Token>,acc:List<&2,Char>) -> Encoded:
  match pending:
    case []:Complete{J.reversed_string(acc,"")}
    case _:Incomplete{}
def step(pending:List<&2,J.Token>,acc:List<&2,Char>,next:List<&2,J.Token> -> List<&2,Char> -> Encoded) -> Encoded:
  match pending:
    case []:Complete{J.reversed_string(acc,"")}
    case J.Visit{value} <> rest:next(List.append(&2,J.Token,J.tokens(value),rest),acc)
    case J.TraceEmit{text} <> rest:next(rest,J.chars(text,acc))
def walk(fuel:Nat,pending:List<&2,J.Token>,acc:List<&2,Char>) -> Encoded:
  match fuel:
    case Zero{}:exhausted(pending,acc)
    case Succ{rest}:step(pending,acc,pending => acc => walk(rest,pending,acc))
def encode(+value:J.Value) -> Encoded:walk(budget(value),[J.Visit{value}],[])
def public(value:Public.View) -> Encoded:encode(view(value))
