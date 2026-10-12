import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import ./state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-binding-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as DumpProvision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
type Token is Data:Token{}
type Rest is Type:Rest{sibling:Array<U32>,graph:G.Graph<F.S>}
def take(value:F.Store()) -> Rest & Col.Column<F.S,Array<U32>>:
  match value:
    case Relation.Store{F.Components{column,sibling},graph}:(Rest{sibling,graph},column)
def put(value:Rest,column:Col.Column<F.S,Array<U32>>) -> F.Store():
  match value:
    case Rest{sibling,graph}:Relation.Store{F.Components{column,sibling},graph}
def view(value:Array<U32>) -> Array<U32> & String:O.u32_array(value)
def text(value:String) -> String:value
def binding() -> Binding.Binding<F.S,F.Store(),Rest,Array<U32>,String,Token,take,put,view>:Binding.bind(~F.S,~F.Store(),~Rest,~Array<U32>,~String,~Token,~take,~put,~view,Identity.component(~F.S,~Array<U32>,"Payload"))
def component_count() -> F.Store() -> List<&2,W.Handle<F.S>> -> F.Store() & List<&2,Maybe<&2,U32>>:Provision.count(~F.S,~F.Store(),~Rest,~Array<U32>,~take,~put)
def component_values() -> F.Store() -> U32 -> F.Store() & List<&2,Maybe<&2,String>>:Provision.values(~F.S,~F.Store(),~Rest,~Array<U32>,~String,~take,~put,~view,~text)
def component_provision() -> DumpProvision.Provision<F.S,F.Store(),Unit,F.empty,component_count(),component_values(),Provision.no_resource>:Provision.component(~F.S,~F.Store(),~Rest,~Array<U32>,~String,~Token,~take,~put,~view,~text,~F.empty,binding())
def resource_identity() -> Schema.Resource<F.S,F.Resources()>:Schema.resource(~F.S,~F.Resources(),"Resources")
def resource_prefix(owner:Unit) -> Unit & List<&2,Maybe<&2,String>>:(owner,[None{}])
def count() -> F.Store() -> List<&2,W.Handle<F.S>> -> F.Store() & List<&2,Maybe<&2,U32>>:Provision.resource_count(~F.S,~F.Store(),~component_count())
def values() -> F.Store() -> U32 -> F.Store() & List<&2,Maybe<&2,String>>:Provision.resource_values(~F.Store(),~component_values())
def resources() -> F.Resources() -> F.Resources() & List<&2,Maybe<&2,String>>:Provision.resources(~F.Resources(),~resource_prefix,~O.u32_array)
def provision() -> DumpProvision.Provision<F.S,F.Store(),F.Resources(),F.empty,count(),values(),resources()>:Provision.with_resource(~F.S,~F.Store(),~F.Resources(),~F.empty,~component_count(),~component_values(),~resource_prefix,~O.u32_array,resource_identity(),component_provision())
def schema_returned(value:DumpProvision.Provision<F.S,F.Store(),F.Resources(),F.empty,count(),values(),resources()>) -> Schema.Schema<F.S,F.Store(),F.Resources()>:
  match value:
    case DumpProvision.Provision{Ordinary.Provision{schema}}:schema
def schema() -> Schema.Schema<F.S,F.Store(),F.Resources()>:schema_returned(provision())

def criteria() -> Filter.Filter<F.S>:Filter.Filter{Some{[1]},[Filter.component(~F.S,~Array<U32>,Binding.identity(~F.S,~F.Store(),~Rest,~Array<U32>,~String,~Token,~take,~put,~view,binding()))],Some{1n}}
