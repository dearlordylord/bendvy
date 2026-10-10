import Base
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as ComponentFixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as ResourceFixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
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
