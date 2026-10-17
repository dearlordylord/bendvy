import Base
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/entity-key.bend as Key
import ../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../src/ecs/restore-raw.bend as R
import ../../../src/ecs/restore-raw-number.bend as N

def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
type Render is Data:
  Text{value:String}
  Raw{value:D.Raw}
  Codec{value:D.Codec}
def raw_items(values:List<&2,D.Raw>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case value <> tail:Raw{value} <> Text{","} <> raw_items(tail,rest)
def raw_fields(values:List<&2,D.Field>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case D.Field{name,value} <> tail:Text{name ++ ":"} <> Raw{value} <> Text{","} <> raw_fields(tail,rest)
def codec_fields(values:List<&2,D.NamedCodec>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []:rest
    case D.NamedCodec{name,value} <> tail:Text{name ++ ":"} <> Codec{value} <> Text{","} <> codec_fields(tail,rest)
def raw_expand(value:D.Raw,rest:List<&2,Render>) -> List<&2,Render>:
  match value:
    case D.Missing{}:Text{"Missing"} <> rest
    case D.Null{}:Text{"Null"} <> rest
    case D.Number{value}:Text{"Number{" ++ U32.show(value) ++ "}"} <> rest
    case D.SignedInteger{negative,magnitude}:Text{"SignedInteger{" ++ Bool.show(negative) ++ "," ++ Nat.show(magnitude) ++ "}"} <> rest
    case D.Float{value}:Text{"Float{bits=" ++ U32.show(F32.bits(value)) ++ "}"} <> rest
    case D.Binary64{high,low}:Text{"Binary64{" ++ U32.show(high) ++ "," ++ U32.show(low) ++ "}"} <> rest
    case D.Text{value}:Text{"Text{" ++ value ++ "}"} <> rest
    case D.Utf16Text{units}:Text{"Utf16Text{" ++ List.show(&2,U32,U32.show,units) ++ "}"} <> rest
    case D.Boolean{value}:Text{"Boolean{" ++ Bool.show(value) ++ "}"} <> rest
    case D.Handle{ns,id}:Text{"Handle{" ++ U32.show(ns) ++ "," ++ key(id) ++ "}"} <> rest
    case D.Array{items}:Text{"Array{"} <> raw_items(items,Text{"}"} <> rest)
    case D.Object{fields}:Text{"Object{"} <> raw_fields(fields,Text{"}"} <> rest)
def codec_expand(value:D.Codec,rest:List<&2,Render>) -> List<&2,Render>:
  match value:
    case D.FiniteNumber{}:Text{"FiniteNumber"} <> rest
    case D.Integer{}:Text{"Integer"} <> rest
    case D.StringValue{}:Text{"StringValue"} <> rest
    case D.BoolValue{}:Text{"BoolValue"} <> rest
    case D.Literal{value}:Text{"Literal{"} <> Raw{value} <> Text{"}"} <> rest
    case D.LiteralValues{values}:Text{"LiteralValues{"} <> raw_items(values,Text{"}"} <> rest)
    case D.LiteralRendered{values,expected}:Text{"LiteralRendered{"} <> raw_items(values,Text{";expected=" ++ expected ++ "}"} <> rest)
    case D.Nullable{inner}:Text{"Nullable{"} <> Codec{inner} <> Text{"}"} <> rest
    case D.ArrayValue{inner}:Text{"ArrayValue{"} <> Codec{inner} <> Text{"}"} <> rest
    case D.Struct{fields}:Text{"Struct{"} <> codec_fields(fields,Text{"}"} <> rest)
    case D.HandleValue{ns}:Text{"HandleValue{" ++ U32.show(ns) ++ "}"} <> rest
type RenderQueue is Data:RenderQueue{items:List<&2,Render>}
def render(fuel:Nat,work:RenderQueue,text:String) -> String:
  match fuel work:
    case _ RenderQueue{[]}:text
    case 0n _:text ++ "RENDER-FUEL-EXHAUSTED"
    case 1n+more RenderQueue{Text{value} <> tail}:render(more,RenderQueue{tail},text ++ value)
    case 1n+more RenderQueue{Raw{value} <> tail}:render(more,RenderQueue{raw_expand(value,tail)},text)
    case 1n+more RenderQueue{Codec{value} <> tail}:render(more,RenderQueue{codec_expand(value,tail)},text)
def raw(value:D.Raw) -> String:render(100000n,RenderQueue{[Raw{value}]},"")
def error(value:R.Error) -> String:
  match value:
    case R.UnsupportedVersion{version}:"UnsupportedVersion(" ++ raw(version) ++ ")"
    case R.Invalid{D.Invalid{path,expected,actual}}:"Invalid(" ++ path ++ "," ++ expected ++ "," ++ raw(actual) ++ ")"
    case R.Invalid{D.FuelExhausted{path}}:"FuelExhausted(" ++ path ++ ")"
def parsed(value:R.Parsed) -> String:
  match value:
    case R.Rejected{original,reason}:"Rejected(" ++ error(reason) ++ ";original=" ++ raw(original) ++ ")"
    case R.Accepted{Snapshot.Snapshot{version,next,entities,resources}}:"Accepted(" ++ U32.show(version) ++ "," ++ U32.show(next) ++ "," ++ Nat.show(List.length(&2,Snapshot.Entity,entities)) ++ "," ++ raw(D.Object{resources}) ++ ")"
def envelope(version:D.Raw,next:D.Raw,entities:D.Raw,resources:D.Raw) -> D.Raw:
  D.Object{[D.Field{"version",version},D.Field{"nextEntity",next},D.Field{"entities",entities},D.Field{"resources",resources}]}
def id() -> D.Raw:D.Object{[D.Field{"index",D.Number{1}},D.Field{"generation",D.Number{0}}]}
def entity(value:D.Raw) -> D.Raw:D.Object{[D.Field{"id",id()},D.Field{"components",value}]}
def report(name:String,value:D.Raw) -> String:name ++ "=" ++ parsed(R.parse(value)) ++ "\n"
def numeric_checked(name:String,value:D.Raw,result:N.Checked) -> String:
  match result:
    case N.Value{number}:name ++ "=" ++ raw(value) ++ ":" ++ U32.show(number) ++ "\n"
    case N.Invalid{}:name ++ "=" ++ raw(value) ++ ":Invalid\n"
def numeric(name:String,+value:D.Raw) -> String:numeric_checked(name,value,N.checked(value))
def main() -> String:
  report("entity",envelope(D.Number{1},D.Number{1},D.Array{[D.Text{"bad-entity"}]},D.Null{})) ++
  report("components",envelope(D.Number{1},D.Number{1},D.Array{[entity(D.Text{"bad-components"})]},D.Null{})) ++
  report("version-first",envelope(D.Text{"bad-version"},D.Null{},D.Null{},D.Null{})) ++
  report("progress-first",envelope(D.Number{1},D.Null{},D.Null{},D.Null{})) ++
  numeric("signed-negative-zero",D.SignedInteger{True{},0n}) ++
  numeric("float-negative-zero",D.Float{F32.neg(0.0)}) ++
  numeric("binary-negative-zero",D.Binary64{2147483648,0}) ++
  numeric("binary-fraction",D.Binary64{1071644672,0}) ++
  numeric("signed-overflow",D.SignedInteger{False{},Nat.mul(65536n,65536n)}) ++
  numeric("binary-max",D.Binary64{1106247679,4292870144})
