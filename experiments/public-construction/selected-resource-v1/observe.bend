import Base
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Ctor
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/experiments/public-conditions/relation-query-check-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as DTOView

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
    case D.Handle{ns,id}:Text{"Handle{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "}"} <> rest
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
def codec(value:D.Codec) -> String:render(100000n,RenderQueue{[Codec{value}]},"")
def error(value:D.Error) -> String:
  match value:
    case D.Invalid{path,expected,actual}:"Invalid{path=" ++ path ++ ";expected=" ++ expected ++ ";actual=" ++ raw(actual) ++ "}"
    case D.FuelExhausted{path}:"FuelExhausted{path=" ++ path ++ "}"
def construction_error(value:Ctor.Error<F.Custom>) -> String:
  match value:
    case Ctor.Validation{value}:"Validation{" ++ error(value) ++ "}"
    case Ctor.Constructor{F.ConstructorStopped{}}:"Constructor{ConstructorStopped}"
def mode(value:F.Mode) -> String:
  match value:
    case F.Valid{}:"Valid"
    case F.ConstructorReject{}:"ConstructorReject"
    case F.AdmissionReject{}:"AdmissionReject"
def input_join(~S:Data,+value:D.Raw,+kind:F.Mode,result:Array<U32> & String) -> F.Input<S> & String:
  (owner,text)=result
  (F.Input{value,kind,owner},"Input{raw=" ++ raw(value) ++ ";mode=" ++ mode(kind) ++ ";owned=" ++ text ++ "}")
def input(~S:Data,value:F.Input<S>) -> F.Input<S> & String:
  match value:
    case F.Input{value,kind,owner}:input_join(~S,value,kind,Dump.u32_array(owner))
def payload_join(~S:Data,+value:D.Raw,+origin:D.Raw,+kind:F.Mode,result:Array<U32> & String) -> F.Payload<S> & String:
  (owner,text)=result
  (F.Payload{value,origin,kind,owner},"Payload{raw=" ++ raw(value) ++ ";origin=" ++ raw(origin) ++ ";mode=" ++ mode(kind) ++ ";owned=" ++ text ++ "}")
def payload(~S:Data,value:F.Payload<S>) -> F.Payload<S> & String:
  match value:
    case F.Payload{value,origin,kind,owner}:payload_join(~S,value,origin,kind,Dump.u32_array(owner))
def refused_join(~S:Data,+failure:Ctor.Error<F.Custom>,value:F.Input<S> & String) -> F.Output<S> & String:
  (owner,text)=value
  (F.Refused{owner,failure},"Refused{" ++ text ++ ";error=" ++ construction_error(failure) ++ "}")
def admission_join(~S:Data,undo:F.Payload<S> -> F.Input<S>,+failure:D.Error,value:F.Payload<S> & String) -> F.Output<S> & String:
  (owner,text)=value
  (F.AdmissionRefused{owner,undo,failure},"AdmissionRefused{cooked=" ++ text ++ ";undo=opaque-retained;error=" ++ error(failure) ++ "}")
def output(~S:Data,value:F.Output<S>) -> F.Output<S> & String:
  match value:
    case F.Refused{owner,failure}:refused_join(~S,failure,input(~S,owner))
    case F.AdmissionRefused{owner,undo,failure}:admission_join(~S,undo,failure,payload(~S,owner))
    case F.Applied{+canonical,undo}:(F.Applied{canonical,undo},"Applied{canonical=" ++ raw(canonical) ++ ";undo=opaque-retained}")
def context(~S:Data,value:F.Context<S>) -> String:
  match value:
    case F.Context{ns,Ctor.FallibleFactory{Persist.Constructed{stored},incoming}}:"Context{namespace=" ++ U32.show(ns) ++ ";factory{identityKey=" ++ Identity.key(~S,~F.Payload<S>,F.identity(~S)) ++ ";storedCodec=" ++ codec(stored) ++ ";inputCodec=" ++ codec(incoming) ++ "}}"
def other_join(+label:String,value:Array<Bool> & String) -> F.Other & String:
  (owner,text)=value
  (F.Other{owner,label},"Other{owned=" ++ text ++ ";label=" ++ label ++ "}")
def other(value:F.Other) -> F.Other & String:
  match value:
    case F.Other{owner,label}:other_join(label,Dump.bool_array(owner))
def resources_join(~S:Data,a:F.Payload<S> & String,b:F.Payload<S> & String,c:F.Other & String) -> F.Resources(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (Product.Owner{a,Product.Owner{b,c}},"Target=" ++ at ++ ";Sibling=" ++ bt ++ ";Other=" ++ ct)
def resources(~S:Data,value:F.Resources(~S)) -> F.Resources(~S) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:resources_join(~S,payload(~S,a),payload(~S,b),other(c))
def unit(value:Unit) -> String:"Unit"
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:F.Resources(~S) & String,c:List<(F.World(~S) -> F.World(~S))> & Nat,d:Array<U32> & String) -> F.World(~S) & String:
  (live,lt)=a
  (resource,rt)=b
  (pending,count)=c
  (store,st)=d
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=" ++ st ++ ";resources={" ++ rt ++ "};events=" ++ List.show(&2,Unit,unit,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),resources(~S,resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending),Dump.u32_array(store))
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case (Unit{},Leaf.Record{Records.Token{},+fields}):((Unit{},Leaf.Record{Records.Token{},fields}),"owners{previous=Unit;token=Token;" ++ Common.fields(~S,fields) ++ "}")
def app_join(~S:Data,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,recipe:Tree.Recipe<F.World(~S),F.Rows(),F.observe(~S)>,a:F.World(~S) & String,b:F.Owners(~S) & String) -> F.Application(~S) & String:
  (current,wt)=a
  (owner,ot)=b
  (App.Application{Schema.Schema{entries},Build.Registered{current,owner,recipe,debug}},"app{schema=" ++ List.show(&2,Fragment.Entry<S>,Common.schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;" ++ wt ++ ";" ++ ot ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case App.Application{Schema.Schema{entries},Build.Registered{current,owner,recipe,debug}}:app_join(~S,entries,debug,recipe,world(~S,current),owners(~S,owner))
def snapshot(~S:Data,value:Maybe<&2,App.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{App.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{Unit{},row},rendered}}}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,Common.schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,DTOView.binding(~S),bindings) ++ ";rows=Product{Unit," ++ U32.show(row) ++ "};rendered=" ++ Common.strings(rendered) ++ "}"
