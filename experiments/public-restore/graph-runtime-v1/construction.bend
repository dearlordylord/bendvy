import Base
import ../basic-world-statefree-v1/factory.bend as Factory
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/decode-construction.bend as Constructor
import ../../../src/ecs/bundle-construction.bend as Build
import ../../../src/ecs/persistence-declaration.bend as Persist

def checked(~S:Data,input:Factory.Input<S>,canonical:D.Raw,invalid:Bool) -> Build.Construction<Factory.Input<S>,Factory.Payload<S>,String>:
  match invalid:
    case True{}:Build.Invalid{input,"resource constructor refusal"}
    case False{}:Factory.build(~S,input,canonical)
def build(~S:Data,input:Factory.Input<S>,canonical:D.Raw) -> Build.Construction<Factory.Input<S>,Factory.Payload<S>,String>:
  match canonical:
    case D.Array{[D.Number{1234},other]}:checked(~S,input,D.Array{[D.Number{1234},other]},True{})
    case other:checked(~S,input,other,False{})
def factory(~S:Data) -> Constructor.FallibleFactory<S,Factory.Input<S>,Factory.Payload<S>,String,Factory.resource_identity(~S),Factory.project(~S),Factory.incoming(~S),build(~S)>:Constructor.fallible_factory(~S,~Factory.Input<S>,~Factory.Payload<S>,~String,~Factory.resource_identity(~S),~Factory.project(~S),~Factory.incoming(~S),~build(~S),Persist.constructed(~S,~Factory.Payload<S>,~Factory.resource_identity(~S),~Factory.project(~S),Factory.codec()))
