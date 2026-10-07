import Base
import feature.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/capabilities.bend as Cap
# Trusted schema author closes the getter; universal gameplay receives only H.
def read(-H:Type,-V:Data,cap:Cap.Read<H,V>,ctx:H) -> H & C.Access<V>:
  match cap:
    case Cap.Read{get}: get(ctx)
def provide(~Ctx:Type,~V:Data,~get:Ctx -> Ctx & C.Access<V>,~body:@-H:Type -> Cap.Read<H,V> -> H -> H & C.Access<V>,ctx:Ctx) -> Ctx & C.Access<V>:
  body(Ctx,Cap.Read{get},ctx)
# Exact repeated descriptors collapse in access scope; conflicts remain validation errors.
def scope_keep(~S:Data,present:Bool,item:SF.Entry<S>,rest:List<&2,SF.Entry<S>>) -> List<&2,SF.Entry<S>>:
  match present:
    case True{}: rest
    case False{}: Con{item,rest}
def scope_seen(~S:Data,items:List<&2,SF.Entry<S>>,+seen:List<&2,SF.Entry<S>>) -> List<&2,SF.Entry<S>>:
  match items:
    case Nil{}: Nil{}
    case +item <> rest: scope_keep(~S,SF.descriptor_present(~S,seen,item),item,scope_seen(~S,rest,Con{item,seen}))
def scope_unique(~S:Data,items:List<&2,SF.Entry<S>>) -> List<&2,SF.Entry<S>>:
  scope_seen(~S,items,Nil{})
# Authoring boundary: actual declared scope checked before closed construction.
def bind_feature(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,definition:F.Definition<S>,required:List<&2,SF.Entry<S>>,owners:Owners) -> SF.Bound<S,Owners,Output>:
  SF.bind_declared(~S,~Owners,~Output,~build,SF.Fragment{scope_unique(~S,F.visibility(~S,F.definition_tree(~S,definition))),owners},required)
def write(-H:Type,-C:Type,-V:Data,cap:Cap.Write<H,C,V>,ctx:H,value:C) -> H:
  match cap:
    case Cap.Write{_,set}: set(ctx,value)
def action(-H:Type,cap:Cap.Action<H>,ctx:H) -> H:
  match cap:
    case Cap.Action{run}: run(ctx)
def provide_action(~Ctx:Type,~run:Ctx -> Ctx,~body:@-H:Type -> Cap.Action<H> -> H -> H,ctx:Ctx) -> Ctx:
  body(Ctx,Cap.Action{run},ctx)
