import Base
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as ComponentFixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import ./presented-test-registration.bend as Ordinary
import ../resource-app-public-v2/fixture.bend as ResourceFixture
import ../resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as Result
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type Action is Data:
  Snapshot{}
  Enable{flag:Bool}
  Invoke{flag:Bool}
def body_finished(~H:Type,fail:Bool,+prior:U32,owner:H) -> H & (T.Outcome<ResourceFixture.Error> & ResourceFixture.Output):
  match fail:
    case False{}:(owner,(T.Success{},ResourceFixture.Output{Array.new(U32,0n,prior)}))
    case True{}:(owner,(T.Failure{ResourceFixture.RolledBack{prior}},ResourceFixture.Output{Array.new(U32,0n,prior)}))
def body_observed(~H:Type,~caps:D.write_ops(~Array<U32>,~U32,H),fail:Bool,result:H & U32) -> H & (T.Outcome<ResourceFixture.Error> & ResourceFixture.Output):
  match result:
    case (owner,+prior):body_finished(~H,fail,prior,Cap.value_set(~H,~Array<U32>,~U32,~caps,owner,Array.new(U32,0n,(prior+1:U32))))
def body_flag(~H:Type,~caps:D.write_ops(~Array<U32>,~U32,H),owner:H,result:Array<Bool> & Bool) -> H & (T.Outcome<ResourceFixture.Error> & ResourceFixture.Output):
  match result:
    case (_,fail):body_observed(~H,~caps,fail,Cap.value_get(~H,~Array<U32>,~U32,~caps,owner))
def body(~H:Type,~caps:D.write_ops(~Array<U32>,~U32,H),args:Input.Args,owner:H) -> H & (T.Outcome<ResourceFixture.Error> & ResourceFixture.Output):
  match args:
    case Input.Args{flags}:body_flag(~H,~caps,owner,Array.get(Bool,flags,0))
def value_view(value:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,value,0)
def declaration(~S:Data) -> D.Declaration<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,D.write_ops(~Array<U32>,~U32),U32>:
  D.write(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~U32,~value_view,~U32.show,Schema.resource(~S,~Array<U32>,"Counter"))
def component_declaration(~S:Data,unit:Unit) -> Presented.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,ComponentFixture.read_ops(Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Projection.Product<C.Access<U32>,Unit>>:
  ComponentFixture.composite_query(~S)
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
    case Query.Clause{name,kind}:name ++ ":" ++ mode(kind)
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{namespace,id,name,access,cursor,slot,clauses}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ slot ++ ":cursor=" ++ U32.show(cursor) ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses)
def debug(~S:Data,~Rows:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{DTO.Product{bindings,DTO.Observation{_,rendered}}}:"Debug{fixtureInitialCursor=0|bindings=" ++ List.show(&2,DTO.Binding<S>,binding(~S),bindings) ++ "|rows=" ++ List.show(&2,String,x=>x,rendered) ++ "}"
def finished(prefix:Maybe<&2,String>) -> String:
  match prefix:
    case None{}:"EMPTY_SEQUENCE"
    case Some{text}:text
def appended(prefix:Maybe<&2,String>,text:String) -> Maybe<&2,String>:
  match prefix:
    case None{}:Some{text}
    case Some{prior}:Some{prior ++ "\n" ++ text}
def world_joined(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,owners:H,recipe:Recipes,enabled:Bool,ownerText:String,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String) -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & String:
  match result:
    case (world,text):(Compact.Application{world,owners,recipe,enabled},"owners=" ++ ownerText ++ "|world{" ++ text ++ "}")
def metadata_joined(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,recipe:Recipes,enabled:Bool,result:H & List<&2,DTO.Binding<S>>) -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & String:
  match result:
    case (owners,bindings):world_joined(~S,~H,~Rows,~Recipes,owners,recipe,enabled,List.show(&2,DTO.Binding<S>,binding(~S),bindings),Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~ComponentFixture.payload,~Dump.u32_array,~U32.show,world))
def observed(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,~metadata:H -> H & List<&2,DTO.Binding<S>>,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>) -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & String:
  match app:
    case Compact.Application{world,owners,recipe,enabled}:metadata_joined(~S,~H,~Rows,~Recipes,world,recipe,enabled,metadata(owners))
def observed_joined(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,label:String,result:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & String) -> String:
  match result:
    case (app,text):next(app,label ++ "|" ++ text)
def snapshot_joined(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,~metadata:H -> H & List<&2,DTO.Binding<S>>,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,result:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> String:
  match result:
    case (app,value):observed_joined(~S,~H,~Rows,~Recipes,next,debug(~S,~Rows,value),observed(~S,~H,~Rows,~Recipes,~metadata,app))
def rejected_flag(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,result:Array<Bool> & Bool) -> String:
  match result:
    case (_,flag):next(app,"RegistrationRejected{arg=" ++ Bool.show(flag) ++ "}")
def rejected_args(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,args:Input.Args) -> String:
  match args:
    case Input.Args{flags}:rejected_flag(~S,~H,~Rows,~Recipes,next,app,Array.get(Bool,flags,0))
def outcome(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,outcome:Sys.Outcome<Unit,ResourceFixture.Error,ResourceFixture.Output>) -> String:
  match outcome:
    case Sys.Succeeded{_,output}:next(app,ResourceFixture.output(output))
    case Sys.Failed{_,ResourceFixture.RolledBack{prior}}:next(app,"Failure{prior=" ++ U32.show(prior) ++ "}")
def invoked(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,next:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> String -> String,result:Result.RunResult<Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,Input.Args,ResourceFixture.Error,ResourceFixture.Output>) -> String:
  match result:
    case Result.Completed{app,value}:outcome(~S,~H,~Rows,~Recipes,next,app,value)
    case Result.RegistrationRejected{app,args}:rejected_args(~S,~H,~Rows,~Recipes,next,app,args)
# The fixed action list is test scheduling data. No finite callback inventory is used.
def go(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,~snapshot:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>,~invoke:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Input.Args -> Result.RunResult<Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,Input.Args,ResourceFixture.Error,ResourceFixture.Output>,~metadata:H -> H & List<&2,DTO.Binding<S>>,actions:List<&2,Action>,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,prefix:Maybe<&2,String>) -> String:
  match actions:
    case []:finished(prefix)
    case Snapshot{} <> rest:snapshot_joined(~S,~H,~Rows,~Recipes,~metadata,app=>text=>go(~S,~H,~Rows,~Recipes,~snapshot,~invoke,~metadata,rest,app,appended(prefix,text)),snapshot(app))
    case Enable{flag} <> rest:go(~S,~H,~Rows,~Recipes,~snapshot,~invoke,~metadata,rest,Ordinary.enable_debug(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~H,~Rows,~Recipes,app,flag),prefix)
    case Invoke{flag} <> rest:invoked(~S,~H,~Rows,~Recipes,app=>text=>go(~S,~H,~Rows,~Recipes,~snapshot,~invoke,~metadata,rest,app,appended(prefix,text)),invoke(app,Input.Args{Array.new(Bool,0n,flag)}))
def registered(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,~snapshot:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>,~invoke:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Input.Args -> Result.RunResult<Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,Input.Args,ResourceFixture.Error,ResourceFixture.Output>,~metadata:H -> H & List<&2,DTO.Binding<S>>,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>) -> String:
  go(~S,~H,~Rows,~Recipes,~snapshot,~invoke,~metadata,[Enable{True{}},Snapshot{},Snapshot{},Enable{False{}},Snapshot{},Enable{True{}},Invoke{False{}},Snapshot{},Invoke{True{}},Snapshot{},Invoke{False{}},Snapshot{},Snapshot{}],app,None{})
def rejected(~S:Data,~H:Type,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,owners:H) -> String:
  "RegistrationRejected"
def register(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  Ordinary.register_component_resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~ComponentFixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~component_declaration(~S),~ComponentFixture.read_body,~D.write_ops(~Array<U32>,~U32),~Input.Args,~ResourceFixture.Error,~ResourceFixture.Output,~U32,~declaration(~S),~body,~String,~registered(~S),~rejected(~S),world,"PositionRead","Update","CounterUpdate","Update")
def replaced(~S:Data,result:C.Replacement<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Caller.Payload>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def seed_if(~S:Data,first:Bool,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,handle:W.Handle<S>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match first:
    case False{}:world
    case True{}:replaced(~S,C.replace(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~S),~Caller.put(~S),~Caller.view,Caller.family(~S),world,handle,Some{Caller.Payload{Array.new(U32,0n,42)}}))
def activated(~S:Data,first:Bool,handle:W.Handle<S>,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Status) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match result:
    case (world,W.Accepted{}):seed_if(~S,first,world,handle)
    case (world,_):world
def reserved(~S:Data,first:Bool,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & W.Reservation<S>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,first,handle,W.activate(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world,handle))
    case (world,_):world
def entities(~S:Data,count:Nat,first:Bool,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match count:
    case 0n:world
    case 1n+k:entities(~S,k,False{},reserved(~S,first,W.reserve_id(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world)))
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  match result:
    case W.Created{_,world}:register(~S,entities(~S,count,True{},world))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~ComponentFixture.empty_store(~S),W.factory(),Array.new(U32,0n,10)))
type Report is Data:
  Report{empty:String,nonempty:String}
