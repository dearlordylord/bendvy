import Base
import ../../../../../../../src/ecs/relation-commands.bend as Notice
import registration.bend as P
import fixture.bend as F
import declarations.bend as D
import observer.bend as O
import ../../../../../../../src/ecs/ordinary-app-reader-fields.bend as RF
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../src/ecs/ordinary-app-composer.bend as App
import ../../../../../../../src/ecs/ordinary-app-records.bend as Pair
import ../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../src/ecs/ordinary-app-recipe.bend as Recipe
import ../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-app-dump.bend as Dump
import ../../../../../../../src/ecs/ordinary-dump-filter.bend as Filter
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../src/ecs/ordinary-binding-provision.bend as Provision

# The existing operational Binding supplies the only identity and storage lens.
# The U32 presenter returns its sole payload owner unchanged.
def value_view(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def counts() -> F.store_type() -> List<&2,W.Handle<F.Schema>> -> F.store_type() & List<&2,Maybe<&2,U32>>:
  Provision.count(~F.Schema,~F.store_type(),~Unit,~U32,~F.take_values,~F.put_values)
def values() -> F.store_type() -> U32 -> F.store_type() & List<&2,Maybe<&2,String>>:
  Provision.values(~F.Schema,~F.store_type(),~Unit,~U32,~U32,~F.take_values,~F.put_values,~value_view,~U32.show)
def schema() -> Schema.Schema<F.Schema,F.store_type(),Unit>:
  Schema.component(~F.Schema,~U32,Binding.identity(~F.Schema,~F.store_type(),~Unit,~U32,~Unit,~Unit,~F.take_values,~F.put_values,~F.presence,F.binding()))
def world_observed(result:F.world_type() & String) -> F.world_type() & DTO.Observation<String>:
  match result:
    case (world,text):(world,DTO.Observation{text,[]})
def world_observe(world:F.world_type()) -> F.world_type() & DTO.Observation<String>:
  world_observed(O.world(world))

def owners_type() -> Type:Unit & (P.metadata_type() & P.provider_type())
def fold_fn() -> owners_type() -> owners_type() & List<&2,Fields.Fields<F.Schema>>:
  Pair.fold_pair(~F.Schema,~Unit,~(P.metadata_type() & P.provider_type()),~Pair.empty(~F.Schema),~RF.fold_meta(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~P.invocation_type(),~Empty,~P.envelope_type(),~P.runner_fn(),~F.all_owner(),~D.all_parameter_type(),~P.metadata_type()))
def app_type() -> Type:
  SchemaApp.Application<F.Schema,F.store_type(),Unit,F.event_type(),owners_type(),String,world_observe,fold_fn()>
def attached(provider:P.provider_type(),parts:F.world_type() & P.metadata_type()) -> app_type():
  match parts:
    case (world,meta):SchemaApp.attached(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~owners_type(),~String,~world_observe,~fold_fn(),schema(),RF.attach(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~P.invocation_type(),~Empty,~P.envelope_type(),~P.runner_fn(),~F.all_owner(),~D.all_parameter_type(),~P.metadata_type(),~Unit,~String,~world_observe,~Pair.empty(~F.Schema),world,Unit{},meta,provider,Recipe.Recipe{},True{}))
def value_text(value:Filter.Value) -> String:
  match value:
    case Filter.Value{key,value}:"value("++F.quoted(key)++","++F.quoted(value)++")"
def row_text(value:Filter.Row<F.Schema>) -> String:
  match value:
    case Filter.Row{entity,components}:"row("++F.handle_json(entity)++","++F.list_json(~Filter.Value,~value_text,components)++")"
def dump_text(value:Maybe<&2,Dump.Dump<F.Schema>>) -> String:
  match value:
    case None{}:"none"
    case Some{Dump.Dump{alive,rows,resources}}:"dump("++U32.show(alive)++","++F.list_json(~Filter.Row<F.Schema>,~row_text,rows)++","++F.list_json(~Filter.Value,~value_text,resources)++")"
def physical_split(schema:Schema.Schema<F.Schema,F.store_type(),Unit>,provider:P.provider_type(),recipe:Recipe.Recipe<F.world_type(),String,world_observe>,debug:Bool,text:String,parts:F.world_type() & P.metadata_type()) -> app_type() & String:
  match parts:
    case (world,meta):(SchemaApp.Application{schema,App.Registered{world,(Unit{},(meta,provider)),recipe,debug}},text)
def physical_returned(schema:Schema.Schema<F.Schema,F.store_type(),Unit>,result:P.app_type() & String) -> app_type() & String:
  match result:
    case (App.Registered{context,(Unit{},provider),_,debug},text):physical_split(schema,provider,Recipe.Recipe{},debug,text,Mixed.split(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,context))
def physical(value:app_type()) -> app_type() & String:
  match value:
    case SchemaApp.Application{schema,App.Registered{world,(Unit{},(meta,provider)),recipe,debug}}:physical_returned(schema,P.physical(App.Registered{Mixed.join(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,world,meta),(Unit{},provider),Recipe.Recipe{},debug}))
def record_physical(label:String,dump:String,result:app_type() & String) -> app_type() & String:
  match result:
    case (app,text):(app,"record("++label++"|"++dump++"|"++text++")\n")
def record_dump(label:String,result:app_type() & Maybe<&2,Dump.Dump<F.Schema>>) -> app_type() & String:
  match result:
    case (app,dump):record_physical(label,dump_text(dump),physical(app))
def record(label:String,criteria:Filter.Filter<F.Schema>,app:app_type()) -> app_type() & String:
  record_dump(label,Dump.schema_snapshot(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~owners_type(),~String,~world_observe,~fold_fn(),~counts(),~values(),~Provision.no_resource,criteria,app))
def all() -> Filter.Filter<F.Schema>:Filter.Filter{None{},[],None{}}
def selected() -> Filter.Filter<F.Schema>:Filter.Filter{Some{[1]},[Filter.component(~F.Schema,~U32,Identity.component(~F.Schema,~U32,"value"))],Some{1n}}
def zero() -> Filter.Filter<F.Schema>:Filter.Filter{None{},[],Some{0n}}
def enabled(app:app_type(),flag:Bool) -> app_type():
  SchemaApp.enabled(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~owners_type(),~String,~world_observe,~fold_fn(),app,flag)
def finish(rows:String,result:app_type() & String) -> String:
  match result:
    case (_,text):rows++text
def disabled(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):finish(rows++text,record("reenabled",all(),enabled(app,True{})))
def limited(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):disabled(rows++text,record("disabled",all(),enabled(app,False{})))
def filtered(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):limited(rows++text,record("zero-limit",zero(),app))
def repeated(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):filtered(rows++text,record("filtered",selected(),app))
def first(result:app_type() & String) -> String:
  match result:
    case (app,text):repeated(text,record("repeat",all(),app))
def initial_record(before:String,result:app_type() & String) -> String:
  match result:
    case (app,text):repeated(before++text,record("repeat",all(),app))

def initial(result:app_type() & String) -> String:
  match result:
    case (app,text):initial_record("record(before|no-dump|"++text++")\n",record("all",all(),app))
def defined(result:P.definition_type()) -> String:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:initial(physical(attached(provider,Mixed.split(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,context))))
    case Ordinary.DefinitionRejected{_,_,_}:"definition-rejected"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"definition-disposal-rejected"
# A real pending publication remains queued throughout every public dump.
def deferred(world:F.world_type()) -> F.world_type():
  W.event_publish(~F.Schema,~F.store_type(),~Unit,~F.event_type(),world,[Notice.Original{F.Value{999}}])
def queued(parts:F.world_type() & P.metadata_type()) -> F.context_type():
  match parts:
    case (world,meta):Mixed.join(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,W.enqueue(~F.Schema,~F.store_type(),~Unit,~F.event_type(),world,deferred),meta)

def ready(setup:F.Setup) -> String:
  match setup:
    case F.Ready{context,_}:defined(P.define_all(queued(Mixed.split(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,context)),"public-dump-reader"))
    case F.SetupFailed{}:"setup-failed"
def main() -> IO(Unit):IO.print(ready(F.setup()))
