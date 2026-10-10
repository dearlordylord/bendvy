import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Full
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import Base
import ./dispatch.bend as Dispatch
import ./schedule-transport.bend as Transport
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import ../operational-v1/dispatch-result.bend as Results
import ../operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import ../recipe-tree-v1/ordinary-unit.bend as Ordinary
import ./declarations.bend as Decl
import ./records.bend as Leaf
import ../runtime-registration-records-v1/records.bend as Stored
import ./composer.bend as Build
import ./metadata.bend as Metadata
import ../recipe-tree-v1/tree.bend as Tree
import ../recipe-tree-v1/leaves.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
def render_first(value:Projection.Product<C.Access<U32>,Unit>) -> String:
  match value:
    case Projection.Product{C.Found{value},_}:"Product(Found:" ++ U32.show(value) ++ ",Unit)"
    case Projection.Product{_,_}:"Product(Missing,Unit)"
def render_last(value:Unit) -> String:
  "Unit"
def Rows(~S:Data) -> Data:
  DTO.Product<DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Unit>>>>
def observe(~S:Data) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & DTO.Observation<Rows(~S)>:
  Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Unit>>>,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S))),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Decl.last_query(~S),~render_last))
def RegisteredApplication(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Decl.Owners(~S),Rows(~S),observe(~S)>
type Setup<S:Data> is Type:
  Ready{app:RegisteredApplication(~S)}
  FirstRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>}
  ResourceRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S)}
  LastRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S),resource:Decl.Resource(~S)}
def snapshot(~S:Data,app:RegisteredApplication(~S)) -> RegisteredApplication(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows(~S)>>>:
  Build.snapshot(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Decl.Owners(~S),~Rows(~S),~observe(~S),Metadata.observe(~S),app)
def last_record(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S),resource:Decl.Resource(~S),result:Decl.LastToken(~S) & Stored.Fields<S>) -> Setup<S>:
  match result:
    case (token,fields):Ready{Build.appended(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S))),~Decl.Last(~S),~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Unit>>>,~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Decl.last_query(~S),~render_last),world,((Unit{},first),resource),Leaf.Record{token,fields},False{})}
def last_defined(~S:Data,first:Decl.First(~S),resource:Decl.Resource(~S),result:Ord.Defined<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Decl.LastRegistry(~S)>) -> Setup<S>:
  match result:
    case Ord.Rejected{world}:LastRejected{world,first,resource}
    case Ord.Defined{world,owner}:last_record(~S,world,first,resource,Stored.component(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~(Unit & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Decl.absent(~S)),~Fixture.absent_body),owner))
def resource_appended(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,(Unit & Decl.First(~S)) & Decl.Resource(~S),DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S)))>) -> Setup<S>:
  match app:
    case Build.Registered{world,((_,first),resource),_,_}:last_defined(~S,first,resource,Ord.observable_define(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~Decl.last_query(~S),~Fixture.absent_body,world,"PositionAbsent","Update"))
def resource_record(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S),result:Decl.ResourceToken(~S) & Stored.Fields<S>) -> Setup<S>:
  match result:
    case (token,fields):resource_appended(~S,Build.appended(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~(Unit & Decl.First(~S)),~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Decl.Resource(~S),~U32,~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S)),world,(Unit{},first),Leaf.Record{token,fields},False{}))
def resource_defined(~S:Data,first:Decl.First(~S),result:P.Defined<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Decl.ResourceRegistry(~S),P.mode(~S,~Array<U32>,~T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,~D.write_ops(~Array<U32>,~U32,T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>),D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)))>) -> Setup<S>:
  match result:
    case P.Rejected{world}:ResourceRejected{world,first}
    case P.Defined{world,owner}:resource_record(~S,world,first,Stored.resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Input.Args,~RF.Error,~RF.Output,~P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body),~P.mode(~S,~Array<U32>,~T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,~D.write_ops(~Array<U32>,~U32,T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>),D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S))),owner))
def first_appended(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit & Decl.First(~S),DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first))>) -> Setup<S>:
  match app:
    case Build.Registered{world,(_,first),_,_}:resource_defined(~S,first,P.define(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body,world,"CounterUpdate","Update"))
def first_record(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,result:Decl.FirstToken(~S) & Stored.Fields<S>) -> Setup<S>:
  match result:
    case (token,fields):first_appended(~S,Build.appended(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Decl.First(~S),~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first),world,Unit{},Leaf.Record{token,fields},False{}))
def first_defined(~S:Data,result:Ord.Defined<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Decl.FirstRegistry(~S)>) -> Setup<S>:
  match result:
    case Ord.Rejected{world}:FirstRejected{world}
    case Ord.Defined{world,owner}:first_record(~S,world,Stored.component(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~(Unit & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S)),~Bodies.component),owner))
def register(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> Setup<S>:
  first_defined(~S,Ord.observable_define(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~Bodies.component,world,"PositionRead","Update"))
def condition_first(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool:
  (world,Bool.not(U32.is_eq(id,3)))
def condition_second(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool:
  (world,Bool.not(U32.is_eq(id,1)))
# Callbacks belong to this actual plan invocation, not to snapshot lifetime.
def callbacks(~S:Data,steps:List<&2,Sch.Step>) -> List<(Decl.Owners(~S) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> U32 -> Results.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),Results.Arguments<Unit,Input.Args>,Results.Error<Q.Error<Unit>,RF.Error>,Results.Output<Unit,RF.Output>>) >:
  match steps:
    case []:[]
    case Sch.System{_,_} <> rest:(owners=>world=>id=>Dispatch.dispatch(~S,owners,world,id)) <> callbacks(~S,rest)
    case _ <> rest:callbacks(~S,rest)
def plan(~S:Data,owners:Decl.Owners(~S)) -> Decl.Owners(~S) & List<&2,Sch.Step>:
  match owners:
    case (((unit,Leaf.Record{t1,+f1}),Leaf.Record{t2,+f2}),Leaf.Record{t3,+f3}):((((unit,Leaf.Record{t1,f1}),Leaf.Record{t2,f2}),Leaf.Record{t3,f3}),[Sch.Phase{"Update"},Sch.System{Dispatch.identity(~S,f1),1},Sch.System{Dispatch.identity(~S,f2),2},Sch.Barrier{},Sch.System{Dispatch.identity(~S,f3),3}])
def run_planned(~S:Data,~condition:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> U32 -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool,debug:Bool,named:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & U32,planned:Decl.Owners(~S) & List<&2,Sch.Step>) -> (Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),Results.Error<Q.Error<Unit>,RF.Error>> & (Maybe<Results.Arguments<Unit,Input.Args>> & List<Results.Output<Unit,RF.Output>>)) & Bool:
  match named:
    case (world,namespace):
      match planned:
        case (owners,+steps):(Transport.run(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Decl.Owners(~S),~Q.Error<Unit>,~RF.Error,~Input.Args,~RF.Output,~condition,callbacks(~S,steps),Sch.Schedule{namespace,"Ordinary",steps,owners},world),debug)
def run(~S:Data,~condition:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> U32 -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool,app:RegisteredApplication(~S)) -> (Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),Results.Error<Q.Error<Unit>,RF.Error>> & (Maybe<Results.Arguments<Unit,Input.Args>> & List<Results.Output<Unit,RF.Output>>)) & Bool:
  match app:
    case Build.Registered{world,owners,_,debug}:run_planned(~S,~condition,debug,W.namespace(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world),plan(~S,owners))
