import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-observation.bend as FieldLeaves
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-component.bend as ComponentRegistration
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field.bend as ResourceRegistration
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as D
import setup-public.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as Application
type Error is Data:
  RolledBack{prior:U32}
type Args is Type:
  Args{values:Array<Bool>}
type Output is Type:
  Output{values:Array<U32>}
def declarations(~S:Data) -> Setup.Declarations<S,Array<U32>,Array<U32>>:
  Setup.Declarations{Identity.component(~S,~Array<U32>,"Position"),Schema.resource(~S,~Array<U32>,"Counter"),Identity.component(~S,~Array<U32>,"Unqueried")}
def value_view(value:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,value,0)
def component_ops(H:Type) -> Type:
  Cap.Read<H,U32> & Cap.Read<H,U32>
def component_done(~H:Type,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,_):(owner,(T.Success{},Unit{}))
def component_second(~H:Type,right:Cap.Read<H,U32>,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,_):component_done(~H,Cap.read_field(~H,~U32,right)(owner))
def component_caps(~H:Type,caps:Cap.Read<H,U32> & Cap.Read<H,U32>,owner:H) -> H & (T.Outcome<Unit> & Unit):
  match caps:
    case (left,right):component_second(~H,right,Cap.read_field(~H,~U32,left)(owner))
def component_body(~H:Type,~caps:component_ops(H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  component_caps(~H,caps,owner)

def read_query(~S:Data) -> O.Declaration<S,Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Cap.Read<Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,I.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,C.Access<U32>>:
  O.read(~S,~Setup.store(~S,~Array<U32>),~Setup.rest(~S,~Array<U32>),~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~value_view,~Setup.resources(~Array<U32>),~U32,~Setup.component_binding(~S,~Array<U32>,~Array<U32>,~U32,~value_view,~declarations(~S)))
def query(~S:Data) -> O.Declaration<S,Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,component_ops(Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),I.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Projection.Product<C.Access<U32>,C.Access<U32>>>:
  O.pair(~S,~Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Cap.Read<Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~Cap.Read<Q.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~I.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~C.Access<U32>,~C.Access<U32>,~read_query(~S),~read_query(~S))
def resource_ops(~S:Data) -> Type -> Type:
  D.write_ops(~S,~Array<U32>,~Setup.resource_identity(~S,~Array<U32>,~Array<U32>,declarations(~S)),~U32)
def resource_declaration(~S:Data) -> D.Declaration<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,resource_ops(~S),U32>:
  D.write(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Array<U32>,~(Unit & Unit),~U32,~Setup.counter_lens(~Array<U32>),~Setup.resource_identity(~S,~Array<U32>,~Array<U32>,declarations(~S)),~Setup.resource_binding(~S,~Array<U32>,~Array<U32>,~declarations(~S)),~value_view,~U32.show)
def resource_replaced(~H:Type,fail:Bool,+prior:U32,owner:H) -> H & (T.Outcome<Error> & Output):
  match fail:
    case False{}:(owner,(T.Success{},Output{Array.new(U32,0n,prior)}))
    case True{}:(owner,(T.Failure{RolledBack{prior}},Output{Array.new(U32,0n,prior)}))
def resource_observed(~S:Data,~H:Type,~caps:resource_ops(~S)(H),fail:Bool,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+prior):resource_replaced(~H,fail,prior,Field.set(~S,~Array<U32>,~Setup.resource_identity(~S,~Array<U32>,~Array<U32>,declarations(~S)),~H,~U32,~caps,owner,Array.new(U32,0n,(prior + 1 : U32))))
def resource_flag(~S:Data,~H:Type,~caps:resource_ops(~S)(H),owner:H,result:Array<Bool> & Bool) -> H & (T.Outcome<Error> & Output):
  match result:
    case (_,fail):resource_observed(~S,~H,~caps,fail,Field.get(~S,~Array<U32>,~Setup.resource_identity(~S,~Array<U32>,~Array<U32>,declarations(~S)),~H,~U32,~caps,owner))
def resource_body(~S:Data,~H:Type,~caps:resource_ops(~S)(H),args:Args,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{values}:resource_flag(~S,~H,~caps,owner,Array.get(Bool,values,0))
def rendered_access(value:C.Access<U32>) -> String:
  match value:
    case C.Found{value}:"Found:" ++ U32.show(value)
    case _:"Absent"
def render_component(value:Projection.Product<C.Access<U32>,C.Access<U32>>) -> String:
  match value:
    case Projection.Product{first,second}:rendered_access(first) ++ ":" ++ rendered_access(second)

def ComponentRegistry(~S:Data) -> Type:
  Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>
def ResourceRegistry(~S:Data) -> Type:
  Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>
def FirstApp(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>,DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaves.component_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~render_component)),Leaf.fold_pair(~S,~Unit,~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>,~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>))>
def RegisteredApp(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,(Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>) & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>,DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,U32>,Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,~U32,~Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaves.component_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~render_component)),~FieldLeaves.resource_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,~resource_declaration(~S))),Leaf.fold_pair(~S,~(Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>),~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>,~Leaf.fold_pair(~S,~Unit,~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>,~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>)),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>))>
def observe(~S:Data) -> W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32> -> W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32> & DTO.Observation<DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,U32>>:
  Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,~U32,~Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaves.component_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~render_component)),~FieldLeaves.resource_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,~resource_declaration(~S)))
def fold(~S:Data) -> ((Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>) & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>) -> ((Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>) & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~(Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>),~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>,~Leaf.fold_pair(~S,~Unit,~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>,~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>)),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>))
def rows(~S:Data) -> Data:
  DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,U32>
def owners(~S:Data) -> Type:
  (Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>) & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>
type SetupResult<S:Data> is Type:
  Ready{app:RegisteredApp(~S)}
  ResourceRejected{app:FirstApp(~S)}
  ComponentRejected{app:Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),Leaf.empty(~S)>}
def resource_ready(~S:Data,app:RegisteredApp(~S)) -> SetupResult<S>:
  Ready{app}
def resource_failed(~S:Data,app:FirstApp(~S)) -> SetupResult<S>:
  ResourceRejected{app}
def component_ready(~S:Data,app:FirstApp(~S)) -> SetupResult<S>:
  ResourceRegistration.register(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~(Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>),~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>>,~Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,C.Access<U32>>>>>,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaves.component_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~render_component)),~Leaf.fold_pair(~S,~Unit,~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>>,~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~component_body)>>)),~resource_ops(~S),~Args,~Error,~Output,~U32,~resource_declaration(~S),~resource_body(~S),~SetupResult<S>,resource_ready(~S),resource_failed(~S),app,"SharedSystem","Update")
def component_failed(~S:Data,app:Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),Leaf.empty(~S)>) -> SetupResult<S>:
  ComponentRejected{app}
def register(~S:Data,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> SetupResult<S>:
  ComponentRegistration.register(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaf.empty(~S),~component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~query(~S),~render_component,~component_body,~SetupResult<S>,component_ready(~S),component_failed(~S),Build.empty(~S,~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,world),"SharedSystem","Update")
