import Base
import ./reference-source/typed.bend as D
import ./gate.bend as G

# Exact #46 diagnostic Raw formatter fragment, not a public save wire format.
type Render is Data:
  Value{value:D.Raw}
  Text{value:String}
def raw_list(values:List<&2,D.Raw>,rest:List<&2,Render>) -> List<&2,Render>:
  match values:
    case []: rest
    case head <> tail: Value{head} <> Text{","} <> raw_list(tail,rest)
def raw_fields(fields:List<&2,D.Field>,rest:List<&2,Render>) -> List<&2,Render>:
  match fields:
    case []: rest
    case D.Field{name,value} <> tail: Text{name ++ ":"} <> Value{value} <> Text{","} <> raw_fields(tail,rest)
def raw_expand(value:D.Raw,rest:List<&2,Render>) -> List<&2,Render>:
  match value:
    case D.Missing{}: Text{"missing"} <> rest
    case D.Null{}: Text{"null"} <> rest
    case D.Number{value}: Text{"u32:" ++ U32.show(value)} <> rest
    case D.SignedInteger{negative,value}: Text{"int:" ++ U32.show(Bool.to_u32(negative)) ++ ":" ++ Nat.show(value)} <> rest
    case D.Float{value}: Text{"f32:" ++ F32.show(value)} <> rest
    case D.Binary64{high,low}: Text{"f64bits:" ++ U32.show(high) ++ ":" ++ U32.show(low)} <> rest
    case D.Text{value}: Text{"str:" ++ value} <> rest
    case D.Utf16Text{units}: Text{"utf16:" ++ List.show(&2,U32,U32.show,units)} <> rest
    case D.Boolean{value}: Text{"bool:" ++ U32.show(Bool.to_u32(value))} <> rest
    case D.Handle{ns,id}: Text{"handle:" ++ U32.show(ns) ++ ":" ++ U32.show(id)} <> rest
    case D.Array{values}: Text{"["} <> raw_list(values,Text{"]"} <> rest)
    case D.Object{fields}: Text{"{"} <> raw_fields(fields,Text{"}"} <> rest)
type RenderQueue is Data:
  RenderQueue{items:List<&2,Render>}
def raw_render(fuel:Nat,work:RenderQueue,suffix:String) -> String:
  match fuel work:
    case _ RenderQueue{[]}: suffix
    case 0n _: suffix ++ "RENDER-FUEL"
    case 1n+more RenderQueue{Text{value} <> tail}: raw_render(more,RenderQueue{tail},suffix ++ value)
    case 1n+more RenderQueue{Value{value} <> tail}: raw_render(more,RenderQueue{raw_expand(value,tail)},suffix)
def raw(value:D.Raw) -> String:
  raw_render(128n,RenderQueue{[Value{value}]},"")

def error(value:D.Error) -> String:
  match value:
    case D.Invalid{path,expected,actual}: "invalid:" ++ path ++ ":" ++ expected ++ ":" ++ raw(actual)
    case D.FuelExhausted{path}: "fuel:" ++ path
def checked(value:D.Checked) -> String:
  match value:
    case D.Accepted{value}: "accepted:" ++ raw(value)
    case D.Rejected{value}: error(value)
def validation(value:G.Validation) -> String:
  match value:
    case G.Skipped{}: "skipped"
    case G.Validated{value}: checked(value)
def field(value:G.Field) -> String:
  match value:
    case G.Omitted{name}: "omitted:" ++ name
    case G.Saved{name,value}: "saved:" ++ name ++ ":" ++ raw(value)
