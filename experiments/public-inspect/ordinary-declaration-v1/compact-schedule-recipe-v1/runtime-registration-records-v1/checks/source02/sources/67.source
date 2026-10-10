import Base
import ./composer.bend as Build
import ./records.bend as Records
import ./ordinary-component.bend as Component
import ../recipe-tree-v1/tree.bend as Tree
import ./resource.bend as Resource
import ../operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Full
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
def absent_declaration(~S:Data,unit:Unit) -> Presented.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  Fixture.absent_query(~S)
def text(~S:Data,~Rows:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{DTO.Product{bindings,DTO.Observation{_,rows}}}:"Debug{bindings=" ++ List.show(&2,DTO.Binding<S>,Full.binding(~S),bindings) ++ "|rows=" ++ List.show(&2,String,x=>x,rows) ++ "}"
def world_observed(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,owners:Owners,recipe:Tree.Recipe<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Rows,observe>,records:List<&2,Records.Fields<S>>,debug:Bool,shown:String,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String) -> Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String:
  match result:
    case (world,state):(Build.Registered{world,owners,recipe,records,debug},shown ++ "|world{" ++ state ++ "}")
def snapshot_observed(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,result:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String:
  match result:
    case (Build.Registered{world,owners,recipe,records,debug},view):world_observed(~S,~Owners,~Rows,~observe,owners,recipe,records,debug,text(~S,~Rows,view),Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~Fixture.payload,~Dump.u32_array,~U32.show,world))
def shown(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe>,flag:Bool) -> Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String:
  snapshot_observed(~S,~Owners,~Rows,~observe,Build.snapshot(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Owners,~Rows,~observe,Build.enabled(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Owners,~Rows,~observe,app,flag)))
def finished(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,first:String,second:String,result:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String) -> String:
  match result:
    case (_,third):first ++ "\n" ++ second ++ "\n" ++ third
def second_shown(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,first:String,result:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String) -> String:
  match result:
    case (app,second):finished(~S,~Owners,~Rows,~observe,first,second,shown(~S,~Owners,~Rows,~observe,app,False{}))
def first_shown(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,result:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe> & String) -> String:
  match result:
    case (app,first):second_shown(~S,~Owners,~Rows,~observe,first,shown(~S,~Owners,~Rows,~observe,app,True{}))
def complete(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe>) -> String:
  first_shown(~S,~Owners,~Rows,~observe,shown(~S,~Owners,~Rows,~observe,app,True{}))
def failed(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe>) -> String:
  "REGISTRATION_REJECTED"
def after_resource(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe>) -> String:
  Component.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Owners,~Rows,~observe,~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~absent_declaration(~S),~Fixture.absent_body,~String,~complete(~S),failed(~S,~Owners,~Rows,~observe),app,"PositionAbsent","Update")
def after_component(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows>,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Owners,Rows,observe>) -> String:
  Resource.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Owners,~Rows,~observe,~D.write_ops(~Array<U32>,~U32),~Unit,~Unit,~Unit,~U32,~Full.declaration(~S),~Bodies.resource,~String,~after_resource(~S),failed(~S,~Owners,~Rows,~observe),app,"CounterUpdate","Update")
def register(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  Component.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S),~Bodies.component,~String,~after_component(~S),failed(~S,~Unit,~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)),Build.empty(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,world),"PositionRead","Update")
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  match result:
    case W.Created{_,world}:register(~S,Full.entities(~S,count,True{},world))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.empty_store(~S),W.factory(),Array.new(U32,0n,10)))
type Report is Data:
  Report{empty:String,populated:String}
