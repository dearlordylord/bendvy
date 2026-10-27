import Base
import ./declarations.bend as Ordinary
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/bundle-construction.bend as Build
import ../../src/ecs/decode-construction.bend as Constructor
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product

def duplicated(+raw:D.Raw) -> D.Raw & D.Raw:(raw,raw)
def incoming(raw:D.Raw) -> D.Raw & D.Raw:duplicated(raw)
def actor_undo(~S:Data,owner:Ordinary.Actor<S>) -> D.Raw:
  match owner:
    case Ordinary.Actor{name,ALeaf{energy}}:D.Object{[D.Field{"name",D.BendvyText{name}},D.Field{"energy",D.Number{energy}}]}
    case Ordinary.Actor{name,ANode{_,_}}:D.Object{[D.Field{"name",D.BendvyText{name}},D.Field{"energy",D.Missing{}}]}
def config_undo(~S:Data,owner:Ordinary.Config<S>) -> D.Raw:
  match owner:
    case Ordinary.Config{enabled,ALeaf{limit}}:D.Object{[D.Field{"enabled",D.Boolean{enabled}},D.Field{"limit",D.Number{limit}}]}
    case Ordinary.Config{enabled,ANode{_,_}}:D.Object{[D.Field{"enabled",D.Boolean{enabled}},D.Field{"limit",D.Missing{}}]}
def actor_values(~S:Data,input:D.Raw,name:D.Raw,energy:D.Raw) -> Build.Construction<D.Raw,Ordinary.Actor<S>,Unit>:
  match name energy:
    case D.BendvyText{name} D.Number{energy}:Build.Constructed{Ordinary.Actor{name,ALeaf{energy}},actor_undo(~S)}
    case _ _:Build.Invalid{input,Unit{}}
def actor_build(~S:Data,input:D.Raw,raw:D.Raw) -> Build.Construction<D.Raw,Ordinary.Actor<S>,Unit>:
  match raw:
    case D.Object{+fields}:actor_values(~S,input,D.field("name",fields),D.field("energy",fields))
    case _:Build.Invalid{input,Unit{}}
def config_values(~S:Data,input:D.Raw,enabled:D.Raw,limit:D.Raw) -> Build.Construction<D.Raw,Ordinary.Config<S>,Unit>:
  match enabled limit:
    case D.Boolean{enabled} D.Number{limit}:Build.Constructed{Ordinary.Config{enabled,ALeaf{limit}},config_undo(~S)}
    case _ _:Build.Invalid{input,Unit{}}
def config_build(~S:Data,input:D.Raw,raw:D.Raw) -> Build.Construction<D.Raw,Ordinary.Config<S>,Unit>:
  match raw:
    case D.Object{+fields}:config_values(~S,input,D.field("enabled",fields),D.field("limit",fields))
    case _:Build.Invalid{input,Unit{}}
def actor_declaration(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>) -> Decl.Constructed<S,Ordinary.Actor<S>,Plan.identity(~S,~Ordinary.Actor<S>,"actor"),Ordinary.actor_project(~S)>:
  match schema:
    case Plan.Schema{Product.Owner{actor,_},_}:actor
def config_declaration(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>) -> Decl.Constructed<S,Ordinary.Config<S>,Plan.identity(~S,~Ordinary.Config<S>,"config"),Ordinary.config_project(~S)>:
  match schema:
    case Plan.Schema{_,Product.Owner{config,_}}:config
def ActorFactory(~S:Data) -> Data:Constructor.FallibleFactory<S,D.Raw,Ordinary.Actor<S>,Unit,Plan.identity(~S,~Ordinary.Actor<S>,"actor"),Ordinary.actor_project(~S),incoming,actor_build(~S)>
def ConfigFactory(~S:Data) -> Data:Constructor.FallibleFactory<S,D.Raw,Ordinary.Config<S>,Unit,Plan.identity(~S,~Ordinary.Config<S>,"config"),Ordinary.config_project(~S),incoming,config_build(~S)>
def actor_factory(~S:Data,declaration:Decl.Constructed<S,Ordinary.Actor<S>,Plan.identity(~S,~Ordinary.Actor<S>,"actor"),Ordinary.actor_project(~S)>) -> ActorFactory(~S):
  Constructor.fallible_factory(~S,~D.Raw,~Ordinary.Actor<S>,~Unit,~Plan.identity(~S,~Ordinary.Actor<S>,"actor"),~Ordinary.actor_project(~S),~incoming,~actor_build(~S),declaration)
def config_factory(~S:Data,declaration:Decl.Constructed<S,Ordinary.Config<S>,Plan.identity(~S,~Ordinary.Config<S>,"config"),Ordinary.config_project(~S)>) -> ConfigFactory(~S):
  Constructor.fallible_factory(~S,~D.Raw,~Ordinary.Config<S>,~Unit,~Plan.identity(~S,~Ordinary.Config<S>,"config"),~Ordinary.config_project(~S),~incoming,~config_build(~S),declaration)
