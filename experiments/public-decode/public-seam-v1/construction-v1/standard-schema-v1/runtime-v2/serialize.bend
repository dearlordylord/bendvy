import Base
import ./materialization.bend as M
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as Mod4
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Mod5
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as Mod6
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Mod7
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Mod8
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-requests.bend as Mod9
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-resource.bend as Mod10
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/standard-schema-v1/runtime-v2/resource.bend as Mod11
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Mod12

# Complete runtime DTO wire: scalar strings are codepoint arrays; F32 is its exact U32 bits.
# This serializer retains every field; the host decoder restores typed strings/bits without projection.
type JsonWork is Data:Literal{text:String} Raw{value:Mod6.Raw} Items{values:List<&2,Mod6.Raw>} Fields{values:List<&2,Mod6.Field>} Field{value:Mod6.Field}
type JsonState is Data:Writing{work:List<&2,JsonWork>,text:String} Written{text:String}
def bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"


def codes(value:String) -> String:
  match value:
    case SNil{}:""
    case SCon{Chr{code},SNil{}}:U32.show(code)
    case SCon{Chr{code},tail}:U32.show(code) ++ "," ++ codes(tail)


def string(value:String) -> String:"{\"$codepoints\":[" ++ codes(value) ++ "]}"


def float(value:F32) -> String:"{\"$f32Bits\":" ++ U32.show(F32.bits(value)) ++ "}"


def show_Unit(~S:Data,+fuel:Nat,value:Unit) -> String:
  match value:
    case Unit{}:"{\"$\":\"Unit\"" ++ "}"


def show_Handle(~S:Data,+fuel:Nat,value:Mod4.Handle<S>) -> String:
  match value:
    case Mod4.Handle{namespace,id}:"{\"$\":\"Handle\"" ++ ",\"namespace\":" ++ U32.show(namespace) ++ ",\"id\":" ++ U32.show(id) ++ "}"


def show_WorldError(~S:Data,+fuel:Nat,value:Mod4.WorldError) -> String:
  match value:
    case Mod4.MissingEntity{}:"{\"$\":\"MissingEntity\"" ++ "}"
    case Mod4.CapacityExceeded{}:"{\"$\":\"CapacityExceeded\"" ++ "}"
    case Mod4.NamespaceExhausted{}:"{\"$\":\"NamespaceExhausted\"" ++ "}"
    case Mod4.SystemIdExhausted{}:"{\"$\":\"SystemIdExhausted\"" ++ "}"


def show_Stamp(~S:Data,+fuel:Nat,value:Mod5.Stamp) -> String:
  match value:
    case Mod5.Stamp{added,changed}:"{\"$\":\"Stamp\"" ++ ",\"added\":" ++ U32.show(added) ++ ",\"changed\":" ++ U32.show(changed) ++ "}"


def show_Entry(~S:Data,+fuel:Nat,value:Mod5.Entry) -> String:
  match value:
    case Mod5.Entry{id,stamp}:"{\"$\":\"Entry\"" ++ ",\"id\":" ++ U32.show(id) ++ ",\"stamp\":" ++ show_Stamp(~S,fuel,stamp) ++ "}"


def show_Outcome(~S:Data,+fuel:Nat,value:Mod12.Outcome<Unit>) -> String:
  match value:
    case Mod12.Success{}:"{\"$\":\"Success\"" ++ "}"
    case Mod12.Failure{error}:"{\"$\":\"Failure\"" ++ ",\"error\":" ++ show_Unit(~S,fuel,error) ++ "}"


def nested_0_tail(~S:Data,+fuel:Nat,value:List<&2,String>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ string(head) ++ nested_0_tail(~S,fuel,tail)


def nested_1_tail(~S:Data,+fuel:Nat,value:List<&2,U32>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ U32.show(head) ++ nested_1_tail(~S,fuel,tail)


def nested_4_tail(~S:Data,+fuel:Nat,value:List<&2,Bool>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ bool(head) ++ nested_4_tail(~S,fuel,tail)


def nested_5_tail(~S:Data,+fuel:Nat,value:List<&2,Unit>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Unit(~S,fuel,head) ++ nested_5_tail(~S,fuel,tail)


def nested_10_tail(~S:Data,+fuel:Nat,value:List<&2,Mod4.WorldError>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_WorldError(~S,fuel,head) ++ nested_10_tail(~S,fuel,tail)


def nested_12_tail(~S:Data,+fuel:Nat,value:List<&2,Mod5.Entry>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Entry(~S,fuel,head) ++ nested_12_tail(~S,fuel,tail)


def nested_0(~S:Data,+fuel:Nat,value:List<&2,String>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ string(head) ++ nested_0_tail(~S,fuel,tail) ++ "]"


def nested_1(~S:Data,+fuel:Nat,value:List<&2,U32>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ U32.show(head) ++ nested_1_tail(~S,fuel,tail) ++ "]"


def nested_4(~S:Data,+fuel:Nat,value:List<&2,Bool>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ bool(head) ++ nested_4_tail(~S,fuel,tail) ++ "]"


def nested_5(~S:Data,+fuel:Nat,value:List<&2,Unit>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Unit(~S,fuel,head) ++ nested_5_tail(~S,fuel,tail) ++ "]"


def nested_10(~S:Data,+fuel:Nat,value:List<&2,Mod4.WorldError>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_WorldError(~S,fuel,head) ++ nested_10_tail(~S,fuel,tail) ++ "]"


def nested_12(~S:Data,+fuel:Nat,value:List<&2,Mod5.Entry>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Entry(~S,fuel,head) ++ nested_12_tail(~S,fuel,tail) ++ "]"


def show_Registration(~S:Data,+fuel:Nat,value:Mod4.RegistrationMeta) -> String:
  match value:
    case Mod4.RegistrationMeta{id,name,access}:"{\"$\":\"RegistrationMeta\"" ++ ",\"id\":" ++ U32.show(id) ++ ",\"name\":" ++ string(name) ++ ",\"access\":" ++ nested_0(~S,fuel,access) ++ "}"


def nested_6_tail(~S:Data,+fuel:Nat,value:List<&2,Mod4.RegistrationMeta>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Registration(~S,fuel,head) ++ nested_6_tail(~S,fuel,tail)


def nested_6(~S:Data,+fuel:Nat,value:List<&2,Mod4.RegistrationMeta>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Registration(~S,fuel,head) ++ nested_6_tail(~S,fuel,tail) ++ "]"


def show_Meta(~S:Data,+fuel:Nat,value:Input.Meta) -> String:
  match value:
    case Input.Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock}:"{\"$\":\"Meta\"" ++ ",\"namespace\":" ++ U32.show(namespace) ++ ",\"nextId\":" ++ U32.show(nextId) ++ ",\"highWater\":" ++ U32.show(highWater) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"events\":" ++ nested_5(~S,fuel,events) ++ ",\"registrations\":" ++ nested_6(~S,fuel,registrations) ++ ",\"nextSystemId\":" ++ U32.show(nextSystemId) ++ ",\"clock\":" ++ U32.show(clock) ++ "}"


def raw_step(value:JsonState) -> JsonState:
  match value:
    case Written{text}:Written{text}
    case Writing{[],text}:Written{text}
    case Writing{Literal{more} <> work,text}:Writing{work,text ++ more}
    case Writing{Items{[]} <> work,text}:Writing{work,text}
    case Writing{Items{[head]} <> work,text}:Writing{Raw{head} <> work,text}
    case Writing{Items{head <> tail} <> work,text}:Writing{Raw{head} <> Literal{","} <> Items{tail} <> work,text}
    case Writing{Fields{[]} <> work,text}:Writing{work,text}
    case Writing{Fields{[head]} <> work,text}:Writing{Field{head} <> work,text}
    case Writing{Fields{head <> tail} <> work,text}:Writing{Field{head} <> Literal{","} <> Fields{tail} <> work,text}
    case Writing{Field{Mod6.Field{name,value}} <> work,text}:Writing{Literal{"{\"$\":\"Field\",\"name\":"} <> Literal{string(name)} <> Literal{",\"value\":"} <> Raw{value} <> Literal{"}"} <> work,text}
    case Writing{Raw{Mod6.Missing{}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Missing\"" ++ "}")}
    case Writing{Raw{Mod6.Null{}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Null\"" ++ "}")}
    case Writing{Raw{Mod6.Number{value}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Number\"" ++ ",\"value\":" ++ U32.show(value) ++ "}")}
    case Writing{Raw{Mod6.SignedInteger{negative,magnitude}} <> work,text}:Writing{work,text ++ ("{\"$\":\"SignedInteger\"" ++ ",\"negative\":" ++ bool(negative) ++ ",\"magnitude\":" ++ Nat.show(magnitude) ++ "}")}
    case Writing{Raw{Mod6.Float{value}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Float\"" ++ ",\"value\":" ++ float(value) ++ "}")}
    case Writing{Raw{Mod6.Binary64{high,low}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Binary64\"" ++ ",\"high\":" ++ U32.show(high) ++ ",\"low\":" ++ U32.show(low) ++ "}")}
    case Writing{Raw{Mod6.Text{value}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Text\"" ++ ",\"value\":" ++ string(value) ++ "}")}
    case Writing{Raw{Mod6.Utf16Text{units}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Utf16Text\"" ++ ",\"units\":" ++ nested_1(~Unit,0n,units) ++ "}")}
    case Writing{Raw{Mod6.Boolean{value}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Boolean\"" ++ ",\"value\":" ++ bool(value) ++ "}")}
    case Writing{Raw{Mod6.Handle{namespace,id}} <> work,text}:Writing{work,text ++ ("{\"$\":\"Handle\"" ++ ",\"namespace\":" ++ U32.show(namespace) ++ ",\"id\":" ++ U32.show(id) ++ "}")}
    case Writing{Raw{Mod6.Array{items}} <> work,text}:Writing{Literal{"{\"$\":\"Array\",\"items\":["} <> Items{items} <> Literal{"]}"} <> work,text}
    case Writing{Raw{Mod6.Object{fields}} <> work,text}:Writing{Literal{"{\"$\":\"Object\",\"fields\":["} <> Fields{fields} <> Literal{"]}"} <> work,text}

def raw_loop(fuel:Nat,value:JsonState) -> String:
  match fuel value:
    case _,Written{text}:text
    case 0n,_:"{\"$transportIncomplete\":\"Raw serialization fuel exhausted\"}"
    case 1n+left,value:raw_loop(left,raw_step(value))

def raw_json(fuel:Nat,value:Mod6.Raw) -> String:raw_loop(fuel,Writing{[Raw{value}],""})

def show_Raw(~S:Data,+fuel:Nat,value:Mod6.Raw) -> String:raw_json(fuel,value)

def show_DecodeError(~S:Data,+fuel:Nat,value:Mod6.Error) -> String:
  match value:
    case Mod6.Invalid{path,expected,actual}:"{\"$\":\"Invalid\"" ++ ",\"path\":" ++ string(path) ++ ",\"expected\":" ++ string(expected) ++ ",\"actual\":" ++ show_Raw(~S,fuel,actual) ++ "}"
    case Mod6.FuelExhausted{path}:"{\"$\":\"FuelExhausted\"" ++ ",\"path\":" ++ string(path) ++ "}"


def show_RequestError(~S:Data,+fuel:Nat,value:Mod7.Error) -> String:
  match value:
    case Mod7.Validation{error}:"{\"$\":\"Validation\"" ++ ",\"error\":" ++ show_DecodeError(~S,fuel,error) ++ "}"
    case Mod7.Entity{error}:"{\"$\":\"Entity\"" ++ ",\"error\":" ++ show_WorldError(~S,fuel,error) ++ "}"


def show_ParseError(~S:Data,+fuel:Nat,value:Business.Error) -> String:
  match value:
    case Business.ParseError{raw}:"{\"$\":\"ParseError\"" ++ ",\"raw\":" ++ show_Raw(~S,fuel,raw) ++ "}"


def show_ConstructorError(~S:Data,+fuel:Nat,value:Mod8.Error<Business.Error>) -> String:
  match value:
    case Mod8.Validation{error}:"{\"$\":\"Validation\"" ++ ",\"error\":" ++ show_DecodeError(~S,fuel,error) ++ "}"
    case Mod8.Constructor{error}:"{\"$\":\"Constructor\"" ++ ",\"error\":" ++ show_ParseError(~S,fuel,error) ++ "}"


def show_ComposedError(~S:Data,+fuel:Nat,value:Mod9.Error<Business.Error>) -> String:
  match value:
    case Mod9.Construction{error}:"{\"$\":\"Construction\"" ++ ",\"error\":" ++ show_ConstructorError(~S,fuel,error) ++ "}"
    case Mod9.Operation{error}:"{\"$\":\"Operation\"" ++ ",\"error\":" ++ show_RequestError(~S,fuel,error) ++ "}"


def show_Input(~S:Data,+fuel:Nat,value:Input.InputView) -> String:
  match value:
    case Input.InputView{raw,words,flags}:"{\"$\":\"InputView\"" ++ ",\"raw\":" ++ show_Raw(~S,fuel,raw) ++ ",\"words\":" ++ nested_1(~S,fuel,words) ++ ",\"flags\":" ++ nested_4(~S,fuel,flags) ++ "}"


def show_Owner(~S:Data,+fuel:Nat,value:Business.View) -> String:
  match value:
    case Business.View{x,y,raw,original,words,flags}:"{\"$\":\"View\"" ++ ",\"x\":" ++ U32.show(x) ++ ",\"y\":" ++ U32.show(y) ++ ",\"raw\":" ++ show_Raw(~S,fuel,raw) ++ ",\"original\":" ++ show_Raw(~S,fuel,original) ++ ",\"words\":" ++ nested_1(~S,fuel,words) ++ ",\"flags\":" ++ nested_4(~S,fuel,flags) ++ "}"


def show_ResourceError(~S:Data,+fuel:Nat,value:Mod10.Error<Business.Error>) -> String:
  match value:
    case Mod10.Construction{error}:"{\"$\":\"Construction\"" ++ ",\"error\":" ++ show_ConstructorError(~S,fuel,error) ++ "}"
    case Mod10.Admission{error}:"{\"$\":\"Admission\"" ++ ",\"error\":" ++ show_DecodeError(~S,fuel,error) ++ "}"


def show_ResourceResult(~S:Data,+fuel:Nat,value:Mod11.ResultView) -> String:
  match value:
    case Mod11.Replaced{canonical,undoAvailable}:"{\"$\":\"Replaced\"" ++ ",\"canonical\":" ++ show_Raw(~S,fuel,canonical) ++ ",\"undoAvailable\":" ++ bool(undoAvailable) ++ "}"
    case Mod11.Refused{owner,error}:"{\"$\":\"Refused\"" ++ ",\"owner\":" ++ show_Input(~S,fuel,owner) ++ ",\"error\":" ++ show_ResourceError(~S,fuel,error) ++ "}"


def nested_7(~S:Data,+fuel:Nat,value:Maybe<&2,Business.View>) -> String:
  match value:
    case None{}:"{\"$\":\"None\"}"
    case Some{value}:"{\"$\":\"Some\",\"value\":" ++ show_Owner(~S,fuel,value) ++ "}"


def nested_8_tail(~S:Data,+fuel:Nat,value:List<&2,Business.View>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Owner(~S,fuel,head) ++ nested_8_tail(~S,fuel,tail)


def nested_11_tail(~S:Data,+fuel:Nat,value:List<&2,Maybe<&2,Business.View>>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ nested_7(~S,fuel,head) ++ nested_11_tail(~S,fuel,tail)


def nested_13(~S:Data,+fuel:Nat,value:Maybe<&2,Input.InputView>) -> String:
  match value:
    case None{}:"{\"$\":\"None\"}"
    case Some{value}:"{\"$\":\"Some\",\"value\":" ++ show_Input(~S,fuel,value) ++ "}"


def show_Packet(~S:Data,+fuel:Nat,value:M.PacketView) -> String:
  match value:
    case M.PacketView{owner,original,canonical}:"{\"$\":\"PacketView\"" ++ ",\"owner\":" ++ nested_7(~S,fuel,owner) ++ ",\"original\":" ++ show_Raw(~S,fuel,original) ++ ",\"canonical\":" ++ show_Raw(~S,fuel,canonical) ++ "}"


def show_Output(~S:Data,+fuel:Nat,value:M.OperationView<S>) -> String:
  match value:
    case M.Accepted{target,spawned,canonical,undoAvailable}:"{\"$\":\"Accepted\"" ++ ",\"target\":" ++ show_Handle(~S,fuel,target) ++ ",\"spawned\":" ++ bool(spawned) ++ ",\"canonical\":" ++ show_Raw(~S,fuel,canonical) ++ ",\"undoAvailable\":" ++ bool(undoAvailable) ++ "}"
    case M.Refused{owner,error}:"{\"$\":\"Refused\"" ++ ",\"owner\":" ++ nested_13(~S,fuel,owner) ++ ",\"error\":" ++ show_ComposedError(~S,fuel,error) ++ "}"


def show_Result(~S:Data,+fuel:Nat,value:M.ResultView<S>) -> String:
  match value:
    case M.Completed{output}:"{\"$\":\"Completed\"" ++ ",\"output\":" ++ show_Output(~S,fuel,output) ++ "}"
    case M.Failed{error}:"{\"$\":\"Failed\"" ++ ",\"error\":" ++ show_Unit(~S,fuel,error) ++ "}"
    case M.Skipped{input}:"{\"$\":\"Skipped\"" ++ ",\"input\":" ++ show_Input(~S,fuel,input) ++ "}"
    case M.RefusedInvocation{}:"{\"$\":\"RefusedInvocation\"" ++ "}"
    case M.Unavailable{}:"{\"$\":\"Unavailable\"" ++ "}"


def nested_8(~S:Data,+fuel:Nat,value:List<&2,Business.View>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Owner(~S,fuel,head) ++ nested_8_tail(~S,fuel,tail) ++ "]"


def nested_9_tail(~S:Data,+fuel:Nat,value:List<&2,M.PacketView>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Packet(~S,fuel,head) ++ nested_9_tail(~S,fuel,tail)


def nested_11(~S:Data,+fuel:Nat,value:List<&2,Maybe<&2,Business.View>>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ nested_7(~S,fuel,head) ++ nested_11_tail(~S,fuel,tail) ++ "]"


def show_Column(~S:Data,+fuel:Nat,value:M.ColumnView) -> String:
  match value:
    case M.ColumnView{supported,slots,stamps}:"{\"$\":\"ColumnView\"" ++ ",\"supported\":" ++ bool(supported) ++ ",\"slots\":" ++ nested_11(~S,fuel,slots) ++ ",\"stamps\":" ++ nested_12(~S,fuel,stamps) ++ "}"


def show_ResourceSnapshot(~S:Data,+fuel:Nat,value:Mod11.Snapshot) -> String:
  match value:
    case Mod11.Snapshot{meta,live,store,resource,pending}:"{\"$\":\"Snapshot\"" ++ ",\"meta\":" ++ show_Meta(~S,fuel,meta) ++ ",\"live\":" ++ nested_4(~S,fuel,live) ++ ",\"store\":" ++ show_Unit(~S,fuel,store) ++ ",\"resource\":" ++ show_Owner(~S,fuel,resource) ++ ",\"pending\":" ++ U32.show(pending) ++ "}"


def show_ResourceObservation(~S:Data,+fuel:Nat,value:Mod11.Report) -> String:
  match value:
    case Mod11.Report{before,after,result,completion}:"{\"$\":\"Report\"" ++ ",\"before\":" ++ show_ResourceSnapshot(~S,fuel,before) ++ ",\"after\":" ++ show_ResourceSnapshot(~S,fuel,after) ++ ",\"result\":" ++ show_ResourceResult(~S,fuel,result) ++ ",\"completion\":" ++ show_Outcome(~S,fuel,completion) ++ "}"
    case Mod11.CreateRefused{}:"{\"$\":\"CreateRefused\"" ++ "}"


def nested_9(~S:Data,+fuel:Nat,value:List<&2,M.PacketView>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Packet(~S,fuel,head) ++ nested_9_tail(~S,fuel,tail) ++ "]"


def show_Mail(~S:Data,+fuel:Nat,value:M.MailView) -> String:
  match value:
    case M.MailView{value,retired,returned,errors}:"{\"$\":\"MailView\"" ++ ",\"value\":" ++ show_Owner(~S,fuel,value) ++ ",\"retired\":" ++ nested_8(~S,fuel,retired) ++ ",\"returned\":" ++ nested_9(~S,fuel,returned) ++ ",\"errors\":" ++ nested_10(~S,fuel,errors) ++ "}"


def show_Snapshot(~S:Data,+fuel:Nat,value:M.Snapshot) -> String:
  match value:
    case M.Snapshot{meta,live,column,mail,pending}:"{\"$\":\"Snapshot\"" ++ ",\"meta\":" ++ show_Meta(~S,fuel,meta) ++ ",\"live\":" ++ nested_4(~S,fuel,live) ++ ",\"column\":" ++ show_Column(~S,fuel,column) ++ ",\"mail\":" ++ show_Mail(~S,fuel,mail) ++ ",\"pending\":" ++ U32.show(pending) ++ "}"


def show_Recovery(~S:Data,+fuel:Nat,value:M.RecoveryView<S>) -> String:
  match value:
    case M.RecoveryView{output,packets}:"{\"$\":\"RecoveryView\"" ++ ",\"output\":" ++ show_Output(~S,fuel,output) ++ ",\"packets\":" ++ nested_9(~S,fuel,packets) ++ "}"


def nested_14_tail(~S:Data,+fuel:Nat,value:List<&2,M.RecoveryView<S>>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ show_Recovery(~S,fuel,head) ++ nested_14_tail(~S,fuel,tail)


def nested_14(~S:Data,+fuel:Nat,value:List<&2,M.RecoveryView<S>>) -> String:
  match value:
    case []:"[]"
    case head <> tail:"[" ++ show_Recovery(~S,fuel,head) ++ nested_14_tail(~S,fuel,tail) ++ "]"


def show_Instance(~S:Data,+fuel:Nat,value:M.InstanceView<S>) -> String:
  match value:
    case M.InstanceView{namespace,id,name,access,recoveries}:"{\"$\":\"InstanceView\"" ++ ",\"namespace\":" ++ U32.show(namespace) ++ ",\"id\":" ++ U32.show(id) ++ ",\"name\":" ++ string(name) ++ ",\"access\":" ++ nested_0(~S,fuel,access) ++ ",\"recoveries\":" ++ nested_14(~S,fuel,recoveries) ++ "}"


def show_Observation(~S:Data,+fuel:Nat,value:M.Report<S>) -> String:
  match value:
    case M.Report{before,committed,barrier,instance,result}:"{\"$\":\"Report\"" ++ ",\"before\":" ++ show_Snapshot(~S,fuel,before) ++ ",\"committed\":" ++ show_Snapshot(~S,fuel,committed) ++ ",\"barrier\":" ++ show_Snapshot(~S,fuel,barrier) ++ ",\"instance\":" ++ show_Instance(~S,fuel,instance) ++ ",\"result\":" ++ show_Result(~S,fuel,result) ++ "}"
    case M.SetupRefused{}:"{\"$\":\"SetupRefused\"" ++ "}"
