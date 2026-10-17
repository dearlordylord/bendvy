import Base
import ../basic-world-statefree-v1/factory.bend as Factory
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/decode-construction.bend as Constructor
import ../../../src/ecs/bundle-construction.bend as Build

def selected(~S:Data,bad:Bool,raw:D.Raw,owned:Array<U32>,canonical:D.Raw) -> Build.Construction<Factory.Input<S>,Factory.Payload<S>,String>:
  match bad:
    case False{}:Build.Constructed{Factory.Payload{canonical,raw,owned},Factory.undo(~S)}
    case True{}:Build.Constructed{Factory.Payload{D.Text{"invalid-stored-value"},raw,owned},Factory.undo(~S)}
def marked(value:D.Raw) -> Bool:
  match value:
    case D.Array{[D.Number{666},D.Number{667}]}:True{}
    case _:False{}
def built(~S:Data,input:Factory.Input<S>,+canonical:D.Raw) -> Build.Construction<Factory.Input<S>,Factory.Payload<S>,String>:
  match input:
    case Factory.Input{raw,owned}:selected(~S,marked(canonical),raw,owned,canonical)
def build(~S:Data,input:Factory.Input<S>,canonical:D.Raw) -> Build.Construction<Factory.Input<S>,Factory.Payload<S>,String>:built(~S,input,canonical)
def Rebound(~S:Data) -> Data:Constructor.FallibleFactory<S,Factory.Input<S>,Factory.Payload<S>,String,Factory.component_identity(~S),Factory.project(~S),Factory.incoming(~S),build(~S)>
def rebound(~S:Data,value:Factory.ComponentFactory(~S)) -> Rebound(~S):
  match value:
    case Constructor.FallibleFactory{declaration,inputCodec}:Constructor.fallible_factory_with_input_codec(~S,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.component_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~build(~S),declaration,inputCodec)
def factory(~S:Data) -> Rebound(~S):rebound(~S,Factory.component_factory(~S))
