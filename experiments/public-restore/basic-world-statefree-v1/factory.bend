import Base
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/persistence-declaration.bend as Persist
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/decode-construction.bend as Constructor
import ../../../src/ecs/bundle-construction.bend as Build

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Input<S:Data> is Type:Input{raw:D.Raw,owned:Array<U32>}
type Payload<S:Data> is Type:Payload{canonical:D.Raw,origin:D.Raw,owned:Array<U32>}
type Context is Type:Context{serial:U32,owned:Array<U32>}
def identity(~S:Data,key:String) -> Identity.Declaration<S,Payload<S>>:
  Identity.component(~S,~Payload<S>,key)
def component_identity(~S:Data) -> Identity.Declaration<S,Payload<S>>:identity(~S,"Values")
def resource_identity(~S:Data) -> Identity.Declaration<S,Payload<S>>:identity(~S,"Settings")
def transient_identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Sentry")
def incoming(~S:Data,value:Input<S>) -> Input<S> & D.Raw:
  match value:
    case Input{+raw,owned}:(Input{raw,owned},raw)
def project(~S:Data,value:Payload<S>) -> Payload<S> & D.Raw:
  match value:
    case Payload{+canonical,origin,owned}:(Payload{canonical,origin,owned},canonical)
def undo(~S:Data,value:Payload<S>) -> Input<S>:
  match value:
    case Payload{_,origin,owned}:Input{origin,owned}
def build(~S:Data,input:Input<S>,canonical:D.Raw) -> Build.Construction<Input<S>,Payload<S>,String>:
  match input:
    case Input{raw,owned}:Build.Constructed{Payload{canonical,raw,owned},undo(~S)}
def codec() -> D.Codec:D.ArrayValue{D.Integer{}}
def ComponentFactory(~S:Data) -> Data:Constructor.FallibleFactory<S,Input<S>,Payload<S>,String,component_identity(~S),project(~S),incoming(~S),build(~S)>
def ResourceFactory(~S:Data) -> Data:Constructor.FallibleFactory<S,Input<S>,Payload<S>,String,resource_identity(~S),project(~S),incoming(~S),build(~S)>
def component_factory(~S:Data) -> ComponentFactory(~S):
  Constructor.fallible_factory(~S,~Input<S>,~Payload<S>,~String,~component_identity(~S),~project(~S),~incoming(~S),~build(~S),Persist.constructed(~S,~Payload<S>,~component_identity(~S),~project(~S),codec()))
def resource_factory(~S:Data) -> ResourceFactory(~S):
  Constructor.fallible_factory(~S,~Input<S>,~Payload<S>,~String,~resource_identity(~S),~project(~S),~incoming(~S),~build(~S),Persist.constructed(~S,~Payload<S>,~resource_identity(~S),~project(~S),codec()))
def supplied(~S:Data,+serial:U32,raw:D.Raw,observed:Array<U32> & U32) -> Context & Input<S>:
  match observed:
    case (owned,value):(Context{(serial+1:U32),Array.set(U32,owned,0,(value+1:U32))},Input{raw,ANode{ALeaf{serial},ALeaf{(serial+1:U32)}}})
def supply(~S:Data,context:Context,raw:D.Raw) -> Context & Input<S>:
  match context:
    case Context{serial,owned}:supplied(~S,serial,raw,Array.get(U32,owned,0))
def context(seed:U32) -> Context:
  Context{seed,ANode{ALeaf{0},ALeaf{999}}}
