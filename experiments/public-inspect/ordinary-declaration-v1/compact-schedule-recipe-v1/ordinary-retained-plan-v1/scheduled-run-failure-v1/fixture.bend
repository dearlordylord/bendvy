import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-leaf-run.bend as LeafRun
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-run.bend as Run
import ./frontend.bend as Front
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import ../../ordinary-schema-debug-v1/owner-observer.bend as Observer
def World(~S:Data) -> Type:
  W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>
def Application(~S:Data) -> Type:
  App.Application<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),Front.rows(~S),Front.observe(~S),Front.fold(~S)>
def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"Component"
    case Fragment.Resource{}:"Resource"
    case Fragment.Event{}:"Event"
    case Fragment.Relation{}:"Relation"
    case Fragment.Service{}:"Service"
def entry(~S:Data,value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{value,key,name}:kind(value) ++ ":" ++ key ++ ":" ++ name
def mode(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"Read"
    case Query.Write{}:"Write"
    case Query.Optional{}:"Optional"
    case Query.With{}:"With"
    case Query.Without{}:"Without"
    case Query.Added{}:"Added"
    case Query.Changed{}:"Changed"
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{key,value}:key ++ ":" ++ mode(value)
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{namespace,id,name,access,cursor,slot,clauses}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ slot ++ ":cursor=" ++ U32.show(cursor) ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses)
def debug(~S:Data,~Rows:Data,value:Maybe<&2,App.Description<S,Rows>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{App.Description{schema,DTO.Product{bindings,DTO.Observation{_,rendered}}}}:"Debug{schema=" ++ List.show(&2,Fragment.Entry<S>,entry(~S),schema) ++ "|bindings=" ++ List.show(&2,DTO.Binding<S>,binding(~S),bindings) ++ "|rendered=" ++ List.show(&2,String,x=>x,rendered) ++ "}"
def record_kind(value:Records.RegistrationKind) -> String:
  match value:
    case Records.ComponentKind{}:"Component"
    case Records.ResourceKind{value}:"Resource:" ++ mode(value)
    case Records.FieldKind{}:"Field"
def record(~S:Data,value:Records.Fields<S>) -> String:
  match value:
    case Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ slot ++ ":cursor=" ++ U32.show(cursor) ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ ":" ++ record_kind(kind)
def complete_owners(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,world:World(~S),flag:Bool,text:String,result:Front.owners(~S) & List<&2,Records.Fields<S>>) -> Application(~S) & String:
  match result:
    case (owners,fields):(App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}},text ++ "|owners=" ++ List.show(&2,Records.Fields<S>,record(~S),fields))
def complete_world(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,owners:Front.owners(~S),debug:Bool,text:String,result:World(~S) & String) -> Application(~S) & String:
  match result:
    case (world,whole):complete_owners(~S,schema,world,debug,text ++ "|world{" ++ whole ++ "}",Front.fold(~S)(owners))
def complete(~S:Data,text:String,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,owners,recipe,flag}}:complete_world(~S,schema,owners,flag,text,Observer.mixed_world(~S,~Array<U32>,~Setup.resources(~Array<U32>),~U32,~Observer.u32_array,~Observer.mixed_resource,~U32.show,world))
def snapshot_returned(~S:Data,result:Application(~S) & Maybe<&2,App.Description<S,Front.rows(~S)>>) -> Application(~S) & String:
  match result:
    case (app,view):complete(~S,debug(~S,~Front.rows(~S),view),app)
def snapshot(~S:Data,flag:Bool,value:Application(~S)) -> Application(~S) & String:
  snapshot_returned(~S,App.snapshot(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),App.enabled(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),value,flag)))
def pending(~S:Data,world:World(~S)) -> World(~S):
  W.event_publish(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world,[99])
def empty_store(~S:Data,value:Unit) -> Setup.store(~S,~Array<U32>):
  Product.Owner{Col.empty(~S,~Array<U32>),Unit{}}
def replaced(~S:Data,result:C.Replacement<World(~S),Array<U32>>) -> World(~S):
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def seed_if(~S:Data,first:Bool,world:World(~S),handle:W.Handle<S>) -> World(~S):
  match first:
    case False{}:world
    case True{}:replaced(~S,C.replace(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Unit,~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,Component.family(~S,~Setup.store(~S,~Array<U32>),~Unit,~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,Setup.component_binding(~S,~Array<U32>,~Array<U32>,~U32,~Front.value_view,~Front.declarations(~S))),world,handle,Some{Array.new(U32,0n,42)}))
def activated(~S:Data,first:Bool,handle:W.Handle<S>,result:World(~S) & W.Status) -> World(~S):
  match result:
    case (world,W.Accepted{}):seed_if(~S,first,world,handle)
    case (world,_):world
def reserved(~S:Data,first:Bool,result:World(~S) & W.Reservation<S>) -> World(~S):
  match result:
    case (world,W.Reserved{+handle}):activated(~S,first,handle,W.activate(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world,handle))
    case (world,_):world
def entities(~S:Data,count:Nat,first:Bool,world:World(~S)) -> World(~S):
  match count:
    case 0n:world
    case 1n+k:entities(~S,k,False{},reserved(~S,first,W.reserve_id(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world)))
