import Base
import ../../../../../../../src/ecs/persistence-declaration.bend as Persist
import ../../../../../../../src/ecs/ordinary-dump-filter.bend as Filter
import ./state.bend as F
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/relation-commands.bend as Relation
import ../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-binding-provision.bend as Provision
import ../../../../../../../src/ecs/ordinary-schema-dump.bend as DumpProvision
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-schema-provision.bend as Ordinary
import ../../../../../../../src/ecs/world.bend as W
import ../owner-observer.bend as O
type Token is Data:Token{}
type Rest is Type:Rest{sibling:Array<U32>,graph:G.Graph<F.S>}
def take(value:F.Store()) -> Rest & Col.Column<F.S,F.Payload>:
  match value:
    case Relation.Store{F.Components{column,sibling},graph}:(Rest{sibling,graph},column)
def put(value:Rest,column:Col.Column<F.S,F.Payload>) -> F.Store():
  match value:
    case Rest{sibling,graph}:Relation.Store{F.Components{column,sibling},graph}
def view(value:F.Payload) -> F.Payload & String:F.present(value)
def text(value:String) -> String:value
def binding() -> Binding.Binding<F.S,F.Store(),Rest,F.Payload,String,Token,take,put,view>:Binding.bind(~F.S,~F.Store(),~Rest,~F.Payload,~String,~Token,~take,~put,~view,Identity.component(~F.S,~F.Payload,"Payload"))
def component_count() -> F.Store() -> List<&2,W.Handle<F.S>> -> F.Store() & List<&2,Maybe<&2,U32>>:Provision.count(~F.S,~F.Store(),~Rest,~F.Payload,~take,~put)
def component_values() -> F.Store() -> U32 -> F.Store() & List<&2,Maybe<&2,String>>:Provision.values(~F.S,~F.Store(),~Rest,~F.Payload,~String,~take,~put,~view,~text)
def component_provision() -> DumpProvision.Provision<F.S,F.Store(),Unit,F.empty,component_count(),component_values(),Provision.no_resource>:Provision.component_transient(~F.S,~F.Store(),~Rest,~F.Payload,~String,~Token,~take,~put,~view,~text,~F.empty,~binding(), Persist.transient(~F.S,~F.Payload,~Binding.identity(~F.S,~F.Store(),~Rest,~F.Payload,~String,~Token,~take,~put,~view,binding())))
def resource_declaration() -> Identity.Declaration<F.S,F.Resources()>:Identity.component(~F.S,~F.Resources(),"Resources")
def resource_prefix(owner:Unit) -> Unit & List<&2,Maybe<&2,String>>:(owner,[None{}])
def count() -> F.Store() -> List<&2,W.Handle<F.S>> -> F.Store() & List<&2,Maybe<&2,U32>>:Provision.resource_count(~F.S,~F.Store(),~component_count())
def values() -> F.Store() -> U32 -> F.Store() & List<&2,Maybe<&2,String>>:Provision.resource_values(~F.Store(),~component_values())
def resources() -> F.Resources() -> F.Resources() & List<&2,Maybe<&2,String>>:Provision.resources(~F.Resources(),~resource_prefix,~O.u32_array)
def provision() -> DumpProvision.Provision<F.S,F.Store(),F.Resources(),F.empty,count(),values(),resources()>:Provision.with_resource_plain(~F.S,~F.Store(),~F.Resources(),~F.empty,~component_count(),~component_values(),~resource_prefix,~O.u32_array,~resource_declaration(), Persist.plain(~F.S,~F.Resources(),~resource_declaration()),component_provision())
def schema_returned(value:DumpProvision.Provision<F.S,F.Store(),F.Resources(),F.empty,count(),values(),resources()>) -> Schema.Schema<F.S,F.Store(),F.Resources()>:
  match value:
    case DumpProvision.Provision{Ordinary.Provision{schema}}:schema
def schema() -> Schema.Schema<F.S,F.Store(),F.Resources()>:schema_returned(provision())

def criteria() -> Filter.Filter<F.S>:Filter.Filter{Some{[1]},[Filter.component(~F.S,~F.Payload,Binding.identity(~F.S,~F.Store(),~Rest,~F.Payload,~String,~Token,~take,~put,~view,binding()))],Some{1n}}
