import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Index
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import ./observer.bend as Whole
import ./population-app.bend as Pop
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
import ./setup.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as Observer
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
    case App.Application{schema,Build.Registered{world,owners,recipe,flag}}:complete_world(~S,schema,owners,flag,text,Whole.mixed_world(~S,~Array<U32>,~Setup.resources(~Array<U32>),~U32,~Observer.u32_array,~Whole.resource,~U32.show,world))
def snapshot_returned(~S:Data,result:Application(~S) & Maybe<&2,App.Description<S,Front.rows(~S)>>) -> Application(~S) & String:
  match result:
    case (app,view):complete(~S,debug(~S,~Front.rows(~S),view),app)
def described(~S:Data,flag:Bool,value:Application(~S)) -> Application(~S) & String:
  snapshot_returned(~S,App.snapshot(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),App.enabled(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),value,flag)))
def role_text(value:Index.Role) -> String:
  match value:
    case Index.Reader{}:"Reader"
    case Index.Writer{}:"Writer"
    case Index.Filter{}:"Filter"
def use(value:Index.Use) -> String:
  match value:
    case Index.Use{namespace,id,name,value,role}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ mode(value) ++ ":" ++ role_text(role)
def access_entry(value:Index.Entry) -> String:
  match value:
    case Index.Entry{Index.Components{},key,uses}:"Component:" ++ key ++ ":" ++ List.show(&2,Index.Use,use,uses)
    case Index.Entry{Index.Resources{},key,uses}:"Resource:" ++ key ++ ":" ++ List.show(&2,Index.Use,use,uses)
    case Index.Entry{Index.Events{},key,uses}:"Event:" ++ key ++ ":" ++ List.show(&2,Index.Use,use,uses)
def access_view(value:Maybe<&2,List<&2,Index.Entry>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{entries}:List.show(&2,Index.Entry,access_entry,entries)
def indexed_done(~S:Data,text:String,result:Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,shown):(app,"index=" ++ text ++ "|" ++ shown)
def indexed(~S:Data,flag:Bool,result:Application(~S) & Maybe<&2,List<&2,Index.Entry>>) -> Application(~S) & String:
  match result:
    case (app,view):indexed_done(~S,access_view(view),described(~S,flag,app))
def component_count(value:Pop.ComponentCount) -> String:
  match value:
    case Pop.ComponentCount{key,count}:key ++ ":" ++ U32.show(count)
def population_text(value:Maybe<&2,Pop.Population>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{Pop.Population{alive,counts}}:"alive=" ++ U32.show(alive) ++ ":" ++ List.show(&2,Pop.ComponentCount,component_count,counts)
def population_returned(~S:Data,result:Application(~S) & Maybe<&2,Pop.Population>) -> Application(~S) & String:
  match result:
    case (app,view):complete(~S,"population=" ++ population_text(view),app)
def snapshot(~S:Data,flag:Bool,value:Application(~S)) -> Application(~S) & String:
  population_returned(~S,Pop.schema_population(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),~Setup.count(~S,~Array<U32>),App.enabled(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),value,flag)))

def output_done(result:Array<U32> & String) -> Front.Output & String:
  match result:
    case (values,text):(Front.Output{values},text)
def output(value:Front.Output) -> Front.Output & String:
  match value:
    case Front.Output{values}:output_done(Observer.u32_array(values))
def error(value:Front.Error) -> String:
  match value:
    case Front.RolledBack{prior}:"RolledBack:" ++ U32.show(prior)
def pending(~S:Data,world:World(~S)) -> World(~S):
  W.event_publish(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world,[99])
def resource_out(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,left:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,token:Records.Token<Front.ResourceRegistry(~S)>,fields:Records.Fields<S>,flag:Bool,status:String,result:World(~S) & (Front.Output & String)) -> Application(~S) & String:
  match result:
    case (world,(out,text)):complete(~S,status ++ ":output=" ++ text,App.Application{schema,Build.Registered{world,(left,Leaf.Record{token,fields}),Tree.Recipe{},flag}})
def resource_success(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,left:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,token:Records.Token<Front.ResourceRegistry(~S)>,fields:Records.Fields<S>,flag:Bool,world:World(~S),out:Front.Output) -> Application(~S) & String:
  resource_out(~S,schema,left,token,fields,flag,"Success",(world,output(out)))
def resource_completed(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,left:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,token:Records.Token<Front.ResourceRegistry(~S)>,fields:Records.Fields<S>,flag:Bool,result:Sys.Outcome<World(~S),Front.Error,Front.Output>) -> Application(~S) & String:
  match result:
    case Sys.Succeeded{world,out}:resource_success(~S,schema,left,token,fields,flag,world,out)
    case Sys.Failed{world,cause}:complete(~S,"Failure:" ++ error(cause),App.Application{schema,Build.Registered{world,(left,Leaf.Record{token,fields}),Tree.Recipe{},flag}})
def rejected_flags(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,left:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,token:Records.Token<Front.ResourceRegistry(~S)>,fields:Records.Fields<S>,flag:Bool,world:World(~S),result:Array<Bool> & String) -> Application(~S) & String:
  match result:
    case (_,text):complete(~S,"Rejected:args=" ++ text,App.Application{schema,Build.Registered{world,(left,Leaf.Record{token,fields}),Tree.Recipe{},flag}})
def resource_returned(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,left:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,flag:Bool,result:Run.TransportResult<S,World(~S),Front.Args,Front.Error,Front.Output,Records.Token<Front.ResourceRegistry(~S)>>) -> Application(~S) & String:
  match result:
    case Run.Completed{token,fields,outcome}:resource_completed(~S,schema,left,token,fields,flag,outcome)
    case Run.RegistrationRejected{token,fields,world,Front.Args{values}}:rejected_flags(~S,schema,left,token,fields,flag,world,Observer.bool_array(values))
def resource(~S:Data,fail:Bool,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,(left,Leaf.Record{token,fields}),_,flag}}:resource_returned(~S,schema,left,flag,Run.run(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.Args,~Front.Error,~Front.Output,~Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.resource_ops(~S),~Front.Args,~Front.Error,~Front.Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.resource_ops(~S),~U32,Front.resource_declaration(~S)),~Front.resource_body(~S)),token,fields,world,Front.Args{Array.new(Bool,0n,fail)}))
def component_completed(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,rest:Unit,right:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,token:Records.Token<Front.ComponentRegistry(~S)>,fields:Records.Fields<S>,flag:Bool,result:Sys.Outcome<World(~S),Q.Error<Unit>,List<&2,Unit>>) -> Application(~S) & String:
  match result:
    case Sys.Succeeded{world,out}:complete(~S,"ComponentSuccess:output=" ++ List.show(&2,Unit,x=>"Unit",out),App.Application{schema,Build.Registered{world,((rest,Leaf.Record{token,fields}),right),Tree.Recipe{},flag}})
    case Sys.Failed{world,_}:complete(~S,"ComponentFailure",App.Application{schema,Build.Registered{world,((rest,Leaf.Record{token,fields}),right),Tree.Recipe{},flag}})
def component_returned(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,rest:Unit,right:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,flag:Bool,result:Run.TransportResult<S,World(~S),Unit & U32,Q.Error<Unit>,List<&2,Unit>,Records.Token<Front.ComponentRegistry(~S)>>) -> Application(~S) & String:
  match result:
    case Run.Completed{token,fields,outcome}:component_completed(~S,schema,rest,right,token,fields,flag,outcome)
    case Run.RegistrationRejected{token,fields,world,_}:complete(~S,"ComponentRejected",App.Application{schema,Build.Registered{world,((rest,Leaf.Record{token,fields}),right),Tree.Recipe{},flag}})
def component(~S:Data,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,((rest,Leaf.Record{token,+fields}),right),_,flag}}:component_returned(~S,schema,rest,right,flag,Run.run(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~(Unit & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~Front.query(~S),~Front.component_body),token,fields,world,(Unit{},LeafRun.current_cursor(~S,fields))))
# Actual ordinary setup edits the unqueried column; no system registration is added.
def unqueried_observed(~S:Data,left:Col.Column<S,Array<U32>>,unit:Unit,column:Col.Column<S,Array<U32>>,status:String,result:Maybe<&1,Array<U32>> & String) -> Setup.store(~S,~Array<U32>) & String:
  match result:
    case (_,text):(Product.Owner{left,Product.Owner{column,unit}},status ++ ":returned=" ++ text)
def unqueried_result(~S:Data,left:Col.Column<S,Array<U32>>,unit:Unit,result:Col.SwapOutcome<S,Array<U32>>) -> Setup.store(~S,~Array<U32>) & String:
  match result:
    case Col.Accepted{column,previous}:unqueried_observed(~S,left,unit,column,"Accepted",Observer.optional(~Array<U32>,~Observer.u32_array,previous))
    case Col.Rejected{column,incoming}:unqueried_observed(~S,left,unit,column,"Rejected",Observer.optional(~Array<U32>,~Observer.u32_array,incoming))
def unqueried_store(~S:Data,id:U32,incoming:Maybe<&1,Array<U32>>,value:Setup.store(~S,~Array<U32>)) -> Setup.store(~S,~Array<U32>) & String:
  match value:
    case Product.Owner{left,Product.Owner{right,unit}}:unqueried_result(~S,left,unit,Col.swap(~S,~Array<U32>,right,id,incoming))
def edited(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,owners:Front.owners(~S),flag:Bool,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:Setup.resources(~Array<U32>),events:List<&2,U32>,pending:List<(World(~S) -> World(~S))>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,result:Setup.store(~S,~Array<U32>) & String) -> Application(~S) & String:
  match result:
    case (store,text):complete(~S,"Unqueried:" ++ text,App.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},owners,Tree.Recipe{},flag}})
def unqueried(~S:Data,id:U32,incoming:Maybe<&1,Array<U32>>,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},owners,_,flag}}:edited(~S,schema,owners,flag,namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,unqueried_store(~S,id,incoming,store))
def status_returned(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,owners:Front.owners(~S),flag:Bool,result:World(~S) & W.Status) -> Application(~S) & String:
  match result:
    case (world,W.Accepted{}):complete(~S,"Deactivated:Accepted",App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}})
    case (world,_):complete(~S,"Deactivated:Rejected",App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}})
def dead(~S:Data,id:U32,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,owners,_,flag}}:status_returned(~S,schema,owners,flag,W.deactivate(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world,W.Handle{1,id}))
def reserved_only(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,owners:Front.owners(~S),flag:Bool,result:World(~S) & W.Reservation<S>) -> Application(~S) & String:
  match result:
    case (world,W.Reserved{W.Handle{namespace,id}}):complete(~S,"Reserved:" ++ U32.show(namespace) ++ ":" ++ U32.show(id),App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}})
    case (world,_):complete(~S,"ReserveRejected",App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}})
def reserve(~S:Data,value:Application(~S)) -> Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,owners,_,flag}}:reserved_only(~S,schema,owners,flag,W.reserve_id(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world))
def joined(~Value:Type,continue:Value -> String -> String,result:Value & String) -> String:
  match result:
    case (value,text):continue(value,text)
def sequence(~Value:Type,actions:List<(Value -> Value & String)>,prefix:String,value:Value) -> String:
  match actions:
    case []:prefix
    case action <> rest:joined(~Value,next=>text=>sequence(~Value,rest,prefix ++ text ++ "\n",next),action(value))
def registered(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,result:Front.SetupResult<S>) -> String:
  match result:
    case Front.Ready{app}:sequence(~Application(~S),[snapshot(~S,False{}),snapshot(~S,True{}),snapshot(~S,True{}),reserve(~S),unqueried(~S,3,Some{Array.new(U32,0n,73)}),snapshot(~S,True{}),unqueried(~S,1,Some{Array.new(U32,0n,71)}),snapshot(~S,True{}),snapshot(~S,False{}),unqueried(~S,1,None{}),snapshot(~S,True{}),dead(~S,1),snapshot(~S,True{}),component(~S),resource(~S,False{}),snapshot(~S,True{}),resource(~S,True{}),snapshot(~S,True{}),resource(~S,False{}),snapshot(~S,True{}),snapshot(~S,True{})],"",App.attached(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),schema,app))
    case _:"REGISTRATION_REJECTED"
def empty_store(~S:Data,value:Unit) -> Setup.store(~S,~Array<U32>):
  Setup.empty(~S,~Array<U32>)(value)
def replaced(~S:Data,result:C.Replacement<World(~S),Array<U32>>) -> World(~S):
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def seed_if(~S:Data,first:Bool,world:World(~S),handle:W.Handle<S>) -> World(~S):
  match first:
    case False{}:world
    case True{}:replaced(~S,C.replace(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Setup.rest(~S,~Array<U32>),~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,Component.family(~S,~Setup.store(~S,~Array<U32>),~Setup.rest(~S,~Array<U32>),~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,Setup.component_binding(~S,~Array<U32>,~Array<U32>,~U32,~Front.value_view,~Front.declarations(~S))),world,handle,Some{Array.new(U32,0n,42)}))
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
def created(~S:Data,count:Nat,result:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> String:
  match result:
    case (schema,W.Created{_,world}):registered(~S,schema,Front.register(~S,W.enqueue(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,entities(~S,count,True{},world),pending(~S))))
    case _:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,App.create(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~empty_store(~S),Setup.schema(~S,~Array<U32>,~Array<U32>,Front.declarations(~S)),W.factory(),Product.Owner{Unit{},Product.Owner{Unit{},Array.new(U32,0n,10)}}))
type Report is Data:
  Report{empty:String,populated:String}
