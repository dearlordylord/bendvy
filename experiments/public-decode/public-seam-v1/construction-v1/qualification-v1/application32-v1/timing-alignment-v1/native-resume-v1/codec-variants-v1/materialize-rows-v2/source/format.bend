import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/serialize.bend as Encode
import /workspace/formal-proofs/bendvy/src/ecs/decode-size.bend as Size
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

def record(tag:String,fields:List<&2,J.Field>) -> J.Value:
  Encode.record(tag,fields)

def nat(value:Nat) -> J.Value:
  J.Text{Nat.show(value)}

def bools(values:List<&2,Bool>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:J.Truth{value} <> bools(rest)

def units(values:List<&2,Unit>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Unit{} <> rest:record("Unit",[]) <> units(rest)

def string_values(values:List<&2,String>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:J.Text{value} <> string_values(rest)

def registration_values(values:List<&2,W.RegistrationMeta>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case W.RegistrationMeta{id,name,access} <> rest:
      record("RegistrationMeta",[J.Field{"id",J.Number{id}},J.Field{"name",J.Text{name}},J.Field{"access",J.Items{string_values(access)}}]) <> registration_values(rest)

type RawTask is Data:
  VisitRaw{value:D.Raw}
  Ready{value:J.Value}
  ArrayEnd{count:Nat}
  ObjectEnd{count:Nat}
  FieldEnd{name:String}

def visits(values:List<&2,D.Raw>) -> List<&2,RawTask>:
  match values:
    case []:[]
    case value <> rest:VisitRaw{value} <> visits(rest)

def field_visits(values:List<&2,D.Field>) -> List<&2,RawTask>:
  match values:
    case []:[]
    case D.Field{name,value} <> rest:VisitRaw{value} <> FieldEnd{name} <> field_visits(rest)

def expand_raw(value:D.Raw) -> List<&2,RawTask>:
  match value:
    case D.Missing{}:[Ready{record("Missing",[])}]
    case D.Null{}:[Ready{record("Null",[])}]
    case D.Number{value}:[Ready{record("Number",[J.Field{"value",J.Number{value}}])}]
    case D.SignedInteger{negative,magnitude}:[Ready{record("SignedInteger",[J.Field{"negative",J.Truth{negative}},J.Field{"magnitude",nat(magnitude)}])}]
    case D.Float{value}:[Ready{record("Float",[J.Field{"bits",J.Number{F32.bits(value)}}])}]
    case D.Binary64{high,low}:[Ready{record("Binary64",[J.Field{"high",J.Number{high}},J.Field{"low",J.Number{low}}])}]
    case D.Text{value}:[Ready{record("Text",[J.Field{"value",J.Text{value}}])}]
    case D.Utf16Text{units}:[Ready{record("Utf16Text",[J.Field{"units",J.Items{J.numbers(units)}}])}]
    case D.Boolean{value}:[Ready{record("Boolean",[J.Field{"value",J.Truth{value}}])}]
    case D.Handle{namespace,id}:[Ready{record("Handle",[J.Field{"namespace",J.Number{namespace}},J.Field{"id",J.Number{id}}])}]
    case D.Array{+items}:List.append(&2,RawTask,visits(items),[ArrayEnd{Encode.length(~D.Raw,items)}])
    case D.Object{+fields}:List.append(&2,RawTask,field_visits(fields),[ObjectEnd{Encode.length(~D.Field,fields)}])

def collect_raw(count:Nat,stack:List<&2,J.Value>,acc:List<&2,J.Value>) -> List<&2,J.Value> & List<&2,J.Value>:
  match count:
    case Zero{}:(stack,acc)
    case Succ{more}:
      match stack:
        case value <> tail:collect_raw(more,tail,value <> acc)
        case []:([],[record("FormatterStackError",[])])

def grouped_raw(tag:String,field:String,value:List<&2,J.Value> & List<&2,J.Value>) -> List<&2,J.Value>:
  match value:
    case (stack,items):record(tag,[J.Field{field,J.Items{items}}]) <> stack

def field_raw(name:String,stack:List<&2,J.Value>) -> List<&2,J.Value>:
  match stack:
    case value <> rest:record("Field",[J.Field{"name",J.Text{name}},J.Field{"value",value}]) <> rest
    case []:[record("FormatterStackError",[])]

def raw_step(todo:List<&2,RawTask>,stack:List<&2,J.Value>,next:List<&2,RawTask> -> List<&2,J.Value> -> J.Value) -> J.Value:
  match todo:
    case []:
      match stack:
        case value <> []:value
        case _:record("FormatterStackError",[])
    case VisitRaw{value} <> rest:next(List.append(&2,RawTask,expand_raw(value),rest),stack)
    case Ready{value} <> rest:next(rest,value <> stack)
    case ArrayEnd{count} <> rest:next(rest,grouped_raw("Array","items",collect_raw(count,stack,[])))
    case ObjectEnd{count} <> rest:next(rest,grouped_raw("Object","fields",collect_raw(count,stack,[])))
    case FieldEnd{name} <> rest:next(rest,field_raw(name,stack))

def raw_walk(fuel:Nat,todo:List<&2,RawTask>,stack:List<&2,J.Value>) -> J.Value:
  match fuel:
    case Zero{}:record("FormatterBudgetError",[])
    case Succ{rest}:raw_step(todo,stack,todo => stack => raw_walk(rest,todo,stack))

def raw_value(+value:D.Raw) -> J.Value:
  raw_walk(Nat.add(1n,Nat.mul(4n,Size.raw_size(value))),[VisitRaw{value}],[])

def input_view(value:Input.InputView) -> J.Value:
  match value:
    case Input.InputView{raw,words,flags}:
      record("InputView",[J.Field{"raw",raw_value(raw)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{bools(flags)}}])

def view(value:Input.View) -> J.Value:
  match value:
    case Input.View{raw,original,words,flags}:
      record("View",[J.Field{"raw",raw_value(raw)},J.Field{"original",raw_value(original)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{bools(flags)}}])

def error_value(value:D.Error) -> J.Value:
  match value:
    case D.Invalid{path,expected,actual}:
      record("Invalid",[J.Field{"path",J.Text{path}},J.Field{"expected",J.Text{expected}},J.Field{"actual",raw_value(actual)}])
    case D.FuelExhausted{path}:record("FuelExhausted",[J.Field{"path",J.Text{path}}])

def constructed(value:Input.ConstructedView) -> J.Value:
  match value:
    case Input.Constructed{owner,recovered}:
      record("Constructed",[J.Field{"owner",view(owner)},J.Field{"recovered",input_view(recovered)}])
    case Input.Rejected{input,error}:
      record("Rejected",[J.Field{"input",input_view(input)},J.Field{"error",error_value(error)}])

def meta_value(value:Input.Meta) -> J.Value:
  match value:
    case Input.Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock}:
      record("Meta",[J.Field{"namespace",J.Number{namespace}},J.Field{"nextId",J.Number{nextId}},J.Field{"highWater",J.Number{highWater}},J.Field{"capacity",J.Number{capacity}},J.Field{"depth",nat(depth)},J.Field{"events",J.Items{units(events)}},J.Field{"registrations",J.Items{registration_values(registrations)}},J.Field{"nextSystemId",J.Number{nextSystemId}},J.Field{"clock",J.Number{clock}}])

def snapshot(value:Input.Snapshot) -> J.Value:
  match value:
    case Input.Snapshot{meta,live,store,resource,pending}:
      record("Snapshot",[J.Field{"meta",meta_value(meta)},J.Field{"live",J.Items{bools(live)}},J.Field{"store",record("Unit",[])},J.Field{"resource",view(resource)},J.Field{"pending",J.Number{pending}}])

def resource_result(value:Input.ResourceResult) -> J.Value:
  match value:
    case Input.Replaced{canonical}:record("Replaced",[J.Field{"canonical",raw_value(canonical)}])
    case Input.Refused{owner,error}:record("Refused",[J.Field{"owner",view(owner)},J.Field{"error",error_value(error)}])

def outcome_value(value:T.Outcome<Unit>) -> J.Value:
  match value:
    case T.Success{}:record("Success",[])
    case T.Failure{Unit{}}:record("Failure",[])

def resource_report(value:Input.ResourceReport) -> J.Value:
  match value:
    case Input.ResourceReport{before,after,result,outcome,pending,undoCount}:
      record("ResourceReport",[J.Field{"before",snapshot(before)},J.Field{"after",snapshot(after)},J.Field{"result",resource_result(result)},J.Field{"outcome",outcome_value(outcome)},J.Field{"pending",J.Number{pending}},J.Field{"undoCount",nat(undoCount)}])
    case Input.CreateRefused{}:record("CreateRefused",[])

def constructed_entry(schema:String,label:String,value:Input.ConstructedView) -> String:
  J.encode(record("ConstructedCase",[J.Field{"schema",J.Text{schema}},J.Field{"label",J.Text{label}},J.Field{"value",constructed(value)}]))

def resource_entry(schema:String,label:String,value:Input.ResourceReport) -> String:
  J.encode(record("ResourceCase",[J.Field{"schema",J.Text{schema}},J.Field{"label",J.Text{label}},J.Field{"value",resource_report(value)}]))

def output(values:List<&2,String>) -> String:
  "[" ++ String.join(values,",") ++ "]"
