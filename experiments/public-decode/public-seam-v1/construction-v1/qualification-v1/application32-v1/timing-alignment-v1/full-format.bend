import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/application.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/owner.bend as Owner
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/public.bend as Public
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/serialize.bend as Encode
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-size.bend as Size
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

# Closed full32 observer format. All source variants retain their payloads.
# Nat is decimal text and F32 is bits, preserving precision and representation.
def record(tag:String,fields:List<&2,J.Field>) -> J.Value:Encode.record(tag,fields)
def nat(value:Nat) -> J.Value:record("Nat",[J.Field{"decimal",J.Text{Nat.show(value)}}])
def strings(values:List<&2,String>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:J.Text{value} <> strings(rest)
def units(values:List<&2,Unit>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Unit{} <> rest:record("Unit",[]) <> units(rest)
type RawTask is Data:VisitRaw{value:D.Raw} Ready{value:J.Value} ArrayEnd{count:Nat} ObjectEnd{count:Nat} FieldEnd{name:String}
def visits(values:List<&2,D.Raw>) -> List<&2,RawTask>:
  match values:
    case []:[]
    case value <> rest:VisitRaw{value} <> visits(rest)
def field_visits(values:List<&2,D.Field>) -> List<&2,RawTask>:
  match values:
    case []:[]
    case D.Field{name,value} <> rest:VisitRaw{value} <> FieldEnd{name} <> field_visits(rest)
def expand(value:D.Raw) -> List<&2,RawTask>:
  match value:
    case D.Missing{}:[Ready{record("Missing",[])}]
    case D.Null{}:[Ready{record("Null",[])}]
    case D.Number{n}:[Ready{record("Number",[J.Field{"value",J.Number{n}}])}]
    case D.SignedInteger{negative,magnitude}:[Ready{record("SignedInteger",[J.Field{"negative",J.Truth{negative}},J.Field{"magnitude",nat(magnitude)}])}]
    case D.Float{value}:[Ready{record("Float",[J.Field{"bits",J.Number{F32.bits(value)}}])}]
    case D.Binary64{high,low}:[Ready{record("Binary64",[J.Field{"high",J.Number{high}},J.Field{"low",J.Number{low}}])}]
    case D.Text{text}:[Ready{record("Text",[J.Field{"value",J.Text{text}}])}]
    case D.Utf16Text{units}:[Ready{record("Utf16Text",[J.Field{"units",J.Items{J.numbers(units)}}])}]
    case D.Boolean{value}:[Ready{record("Boolean",[J.Field{"value",J.Truth{value}}])}]
    case D.Handle{namespace,id}:[Ready{record("Handle",[J.Field{"namespace",J.Number{namespace}},J.Field{"id",J.Number{id}}])}]
    case D.Array{+items}:List.append(&2,RawTask,visits(items),[ArrayEnd{Encode.length(~D.Raw,items)}])
    case D.Object{+fields}:List.append(&2,RawTask,field_visits(fields),[ObjectEnd{Encode.length(~D.Field,fields)}])
def raw_step(todo:List<&2,RawTask>,stack:List<&2,J.Value>,next:List<&2,RawTask> -> List<&2,J.Value> -> J.Value) -> J.Value:
  match todo:
    case []:
      match stack:
        case value <> []:value
        case _:record("FormatterStackError",[])
    case VisitRaw{value} <> rest:next(List.append(&2,RawTask,expand(value),rest),stack)
    case Ready{value} <> rest:next(rest,value <> stack)
    case ArrayEnd{n} <> rest:next(rest,Encode.grouped("Array","items",Encode.collect(n,stack,[])))
    case ObjectEnd{n} <> rest:next(rest,Encode.grouped("Object","fields",Encode.collect(n,stack,[])))
    case FieldEnd{name} <> rest:next(rest,Encode.field(name,stack))
def raw_walk(fuel:Nat,todo:List<&2,RawTask>,stack:List<&2,J.Value>) -> J.Value:
  match fuel:
    case Zero{}:record("FormatterBudgetError",[])
    case Succ{rest}:raw_step(todo,stack,todo => stack => raw_walk(rest,todo,stack))
def raw(+value:D.Raw) -> J.Value:raw_walk(Nat.add(1n,Nat.mul(4n,Size.raw_size(value))),[VisitRaw{value}],[])
def owner(value:Owner.View) -> J.Value:
  match value:
    case Owner.View{value,original,words,flags}:record("View",[J.Field{"raw",raw(value)},J.Field{"original",raw(original)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{Encode.bools(flags)}}])
def input(value:Owner.InputView) -> J.Value:
  match value:
    case Owner.InputView{value,words,flags}:record("InputView",[J.Field{"raw",raw(value)},J.Field{"words",J.Items{J.numbers(words)}},J.Field{"flags",J.Items{Encode.bools(flags)}}])
def maybe_owner(value:Maybe<&2,Owner.View>) -> J.Value:
  match value:
    case None{}:record("None",[])
    case Some{value}:record("Some",[J.Field{"value",owner(value)}])
def maybe_input(value:Maybe<&2,Owner.InputView>) -> J.Value:
  match value:
    case None{}:record("None",[])
    case Some{value}:record("Some",[J.Field{"value",input(value)}])
def owners(values:List<&2,Maybe<&2,Owner.View>>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:maybe_owner(value) <> owners(rest)
def numbers(values:List<&2,Maybe<&2,U32>>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:Encode.maybe_number(value) <> numbers(rest)
def stamp(value:Life.Stamp) -> J.Value:
  match value:
    case Life.Stamp{added,changed}:record("Stamp",[J.Field{"added",J.Number{added}},J.Field{"changed",J.Number{changed}}])
def stamps(values:List<&2,Life.Entry>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Life.Entry{id,value} <> rest:record("Entry",[J.Field{"id",J.Number{id}},J.Field{"stamp",stamp(value)}]) <> stamps(rest)
def packet(value:App.PacketView) -> J.Value:
  match value:
    case App.PacketView{value,original,canonical}:record("PacketView",[J.Field{"owner",maybe_owner(value)},J.Field{"original",raw(original)},J.Field{"canonical",raw(canonical)}])
def packets(values:List<&2,App.PacketView>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:packet(value) <> packets(rest)
def errors(values:List<&2,W.WorldError>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:Encode.world_error(value) <> errors(rest)
def payload(value:App.QueuedPayload) -> J.Value:
  match value:
    case App.ComponentPayload{value}:record("ComponentPayload",[J.Field{"owner",owner(value)}])
    case App.MarkerPayload{value}:record("MarkerPayload",[J.Field{"value",J.Number{value}}])
def receipts(values:List<&2,App.Queued>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case App.Queued{kind,system,namespace,id,value} <> rest:record("Queued",[J.Field{"kind",J.Text{kind}},J.Field{"system",J.Text{system}},J.Field{"namespace",J.Number{namespace}},J.Field{"id",J.Number{id}},J.Field{"payload",payload(value)}]) <> receipts(rest)
def column(value:App.ColumnView) -> J.Value:
  match value:
    case App.ColumnView{supported,slots,entries}:record("ColumnView",[J.Field{"supported",J.Truth{supported}},J.Field{"slots",J.Items{owners(slots)}},J.Field{"stamps",J.Items{stamps(entries)}}])
def marker(value:App.MarkerView) -> J.Value:
  match value:
    case App.MarkerView{slots,entries}:record("MarkerView",[J.Field{"slots",J.Items{numbers(slots)}},J.Field{"stamps",J.Items{stamps(entries)}}])
    case App.UnsupportedMarker{}:record("UnsupportedMarker",[])
def store(value:App.StoreView) -> J.Value:
  match value:
    case App.StoreView{values,mark,returned,failed,queued}:record("StoreView",[J.Field{"values",column(values)},J.Field{"marker",marker(mark)},J.Field{"returned",J.Items{packets(returned)}},J.Field{"errors",J.Items{errors(failed)}},J.Field{"receipts",J.Items{receipts(queued)}}])
def registrations(values:List<&2,W.RegistrationMeta>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case W.RegistrationMeta{id,name,access} <> rest:record("RegistrationMeta",[J.Field{"id",J.Number{id}},J.Field{"name",J.Text{name}},J.Field{"access",J.Items{strings(access)}}]) <> registrations(rest)
def meta(value:App.Meta) -> J.Value:
  match value:
    case App.Meta{namespace,nextId,highWater,capacity,depth,events,registered,nextSystemId,clock}:record("Meta",[J.Field{"namespace",J.Number{namespace}},J.Field{"nextId",J.Number{nextId}},J.Field{"highWater",J.Number{highWater}},J.Field{"capacity",J.Number{capacity}},J.Field{"depth",nat(depth)},J.Field{"events",J.Items{units(events)}},J.Field{"registrations",J.Items{registrations(registered)}},J.Field{"nextSystemId",J.Number{nextSystemId}},J.Field{"clock",J.Number{clock}}])
def snapshot(value:App.Snapshot) -> J.Value:
  match value:
    case App.Snapshot{metadata,live,values,resource,pending}:record("Snapshot",[J.Field{"meta",meta(metadata)},J.Field{"live",J.Items{Encode.bools(live)}},J.Field{"store",store(values)},J.Field{"resource",owner(resource)},J.Field{"pending",J.Number{pending}}])
def error(value:D.Error) -> J.Value:
  match value:
    case D.Invalid{path,expected,actual}:record("Invalid",[J.Field{"path",J.Text{path}},J.Field{"expected",J.Text{expected}},J.Field{"actual",raw(actual)}])
    case D.FuelExhausted{path}:record("FuelExhausted",[J.Field{"path",J.Text{path}}])
def request_error(value:Request.Error) -> J.Value:
  match value:
    case Request.Validation{value}:record("Validation",[J.Field{"error",error(value)}])
    case Request.Entity{value}:record("Entity",[J.Field{"error",Encode.world_error(value)}])
def handle(~S:Data,value:W.Handle<S>) -> J.Value:
  match value:
    case W.Handle{namespace,id}:record("Handle",[J.Field{"namespace",J.Number{namespace}},J.Field{"id",J.Number{id}}])
def operation(~S:Data,value:App.OperationView<S>) -> J.Value:
  match value:
    case App.Accepted{target,spawned,canonical,undo}:record("Accepted",[J.Field{"target",handle(~S,target)},J.Field{"spawned",J.Truth{spawned}},J.Field{"canonical",raw(canonical)},J.Field{"undoAvailable",J.Truth{undo}}])
    case App.Refused{value,failed}:record("Refused",[J.Field{"owner",maybe_input(value)},J.Field{"error",request_error(failed)}])
def resource(value:App.ResourceView) -> J.Value:
  match value:
    case App.ResourceReplaced{canonical,undo}:record("ResourceReplaced",[J.Field{"canonical",raw(canonical)},J.Field{"undoAvailable",J.Truth{undo}}])
    case App.ResourceRefused{value,failed}:record("ResourceRefused",[J.Field{"owner",input(value)},J.Field{"error",error(failed)}])
def output(~S:Data,value:App.OutputView<S>) -> J.Value:
  match value:
    case App.ComponentView{value}:record("ComponentView",[J.Field{"value",operation(~S,value)}])
    case App.ResourceOutputView{value}:record("ResourceOutputView",[J.Field{"value",resource(value)}])
def recoveries(~S:Data,values:List<&2,App.RecoveryView<S>>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case App.RecoveryView{value,returned} <> rest:record("RecoveryView",[J.Field{"output",output(~S,value)},J.Field{"packets",J.Items{packets(returned)}}]) <> recoveries(~S,rest)
def pending(values:List<&2,App.PendingView>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case App.PendingView{Unit{},failed} <> rest:record("PendingView",[J.Field{"owner",record("Unit",[])},J.Field{"error",Encode.world_error(failed)}]) <> pending(rest)
def instance(~S:Data,value:App.InstanceView<S>) -> J.Value:
  match value:
    case App.InstanceView{namespace,id,name,access,recovered,queued}:record("InstanceView",[J.Field{"namespace",J.Number{namespace}},J.Field{"id",J.Number{id}},J.Field{"name",J.Text{name}},J.Field{"access",J.Items{strings(access)}},J.Field{"recoveries",J.Items{recoveries(~S,recovered)}},J.Field{"pending",J.Items{pending(queued)}}])
def result(~S:Data,value:App.ResultView<S>) -> J.Value:
  match value:
    case App.Completed{value}:record("Completed",[J.Field{"output",output(~S,value)}])
    case App.Failed{Unit{}}:record("Failed",[J.Field{"error",record("Unit",[])}])
    case App.InvocationRefused{value,operation,target}:record("InvocationRefused",[J.Field{"input",input(value)},J.Field{"operation",Encode.mode(operation)},J.Field{"target",handle(~S,target)}])
def report(~S:Data,value:App.Report<S>) -> J.Value:
  match value:
    case App.Report{original,before,committed,barrier,state,out}:record("Report",[J.Field{"original",input(original)},J.Field{"before",snapshot(before)},J.Field{"committed",snapshot(committed)},J.Field{"barrier",snapshot(barrier)},J.Field{"instance",instance(~S,state)},J.Field{"result",result(~S,out)}])
    case App.SetupRefused{}:record("SetupRefused",[])
def entities(values:List<&2,Public.Entity>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Public.Entity{id,value,marker} <> rest:record("Entity",[J.Field{"id",J.Number{id}},J.Field{"value",maybe_owner(value)},J.Field{"marker",Encode.maybe_number(marker)}]) <> entities(rest)
def public_pending(values:List<&2,Public.Pending>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Public.Pending{kind,system,target,value} <> rest:record("Pending",[J.Field{"kind",J.Text{kind}},J.Field{"system",J.Text{system}},J.Field{"target",J.Number{target}},J.Field{"payload",payload(value)}]) <> public_pending(rest)
def state(value:Public.State) -> J.Value:
  match value:
    case Public.State{rows,resource,pending,count,consistent}:record("State",[J.Field{"entities",J.Items{entities(rows)}},J.Field{"resource",owner(resource)},J.Field{"pending",J.Items{public_pending(pending)}},J.Field{"logicalPendingCount",J.Number{count}},J.Field{"receiptLoweringMatches",J.Truth{consistent}}])
    case Public.Unsupported{value}:record("Unsupported",[J.Field{"snapshot",snapshot(value)}])
def checked(value:Public.Checked) -> J.Value:
  match value:
    case Public.Accepted{target,spawned,canonical}:record("Accepted",[J.Field{"target",Encode.maybe_number(target)},J.Field{"spawned",J.Truth{spawned}},J.Field{"canonical",raw(canonical)}])
    case Public.Refused{value,failed}:record("Refused",[J.Field{"input",maybe_input(value)},J.Field{"error",request_error(failed)}])
    case Public.SystemFailed{Unit{}}:record("SystemFailed",[J.Field{"error",record("Unit",[])}])
    case Public.InvocationRefused{value,operation,namespace,target}:record("InvocationRefused",[J.Field{"input",input(value)},J.Field{"operation",Encode.mode(operation)},J.Field{"namespace",J.Number{namespace}},J.Field{"target",J.Number{target}}])
def view(value:Public.View) -> J.Value:
  match value:
    case Public.View{original,before,committed,barrier,out}:record("View",[J.Field{"original",input(original)},J.Field{"before",state(before)},J.Field{"committed",state(committed)},J.Field{"barrier",state(barrier)},J.Field{"checked",checked(out)}])
    case Public.SetupRefused{}:record("SetupRefused",[])
def whole(~S:Data,+value:App.Report<S>) -> J.Value:record("Whole",[J.Field{"public",view(Public.view(~S,value))},J.Field{"native",report(~S,value)}])
def whole_value(~S:Data,value:Public.Whole<S>) -> J.Value:
  match value:
    case Public.Whole{public,native}:record("Whole",[J.Field{"public",view(public)},J.Field{"native",report(~S,native)}])
def completed(value:Encode.Encoded) -> String:
  match value:
    case Encode.Complete{text}:text
    case Encode.Incomplete{}:"FORMATTER_INCOMPLETE"
