import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Stored
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-component.bend as ComponentRegistration
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource.bend as ResourceRegistration
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import ./fixture-full.bend as Full
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import Base
import ./dispatch.bend as Dispatch
import ./schedule-transport.bend as Transport
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as Results
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import ./declarations.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import ./metadata.bend as Metadata
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation.bend as Leaves
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
def first_fold(~S:Data) -> (Unit & Decl.First(~S)) -> (Unit & Decl.First(~S)) & List<&2,Stored.Fields<S>>:
  Leaf.fold_pair(~S,~Unit,~Decl.First(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Decl.FirstToken(~S)))
def resource_fold(~S:Data) -> ((Unit & Decl.First(~S)) & Decl.Resource(~S)) -> ((Unit & Decl.First(~S)) & Decl.Resource(~S)) & List<&2,Stored.Fields<S>>:
  Leaf.fold_pair(~S,~(Unit & Decl.First(~S)),~Decl.Resource(~S),~first_fold(~S),~Leaf.observed(~S,~Decl.ResourceToken(~S)))
def fold(~S:Data) -> Decl.Owners(~S) -> Decl.Owners(~S) & List<&2,Stored.Fields<S>>:
  Leaf.fold_pair(~S,~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~Decl.Last(~S),~resource_fold(~S),~Leaf.observed(~S,~Decl.LastToken(~S)))
def RegisteredApplication(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Decl.Owners(~S),Rows(~S),observe(~S),fold(~S)>
type Setup<S:Data> is Type:
  Ready{app:RegisteredApplication(~S)}
  FirstRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>}
  ResourceRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S)}
  LastRejected{world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,first:Decl.First(~S),resource:Decl.Resource(~S)}
def snapshot(~S:Data,app:RegisteredApplication(~S)) -> RegisteredApplication(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows(~S)>>>:
  Build.snapshot(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Decl.Owners(~S),~Rows(~S),~observe(~S),~fold(~S),app)
def ready(~S:Data,app:RegisteredApplication(~S)) -> Setup<S>:
  Ready{app}
def last_failed(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>, (Unit & Decl.First(~S)) & Decl.Resource(~S),DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S))),resource_fold(~S)>) -> Setup<S>:
  match app:
    case Build.Registered{world,((_,first),resource),_,_}:LastRejected{world,first,resource}
def resource_appended(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>, (Unit & Decl.First(~S)) & Decl.Resource(~S),DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S))),resource_fold(~S)>) -> Setup<S>:
  ComponentRegistration.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~DTO.Product<DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,U32>,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~U32,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~Leaves.resource_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,~Full.declaration(~S))),~resource_fold(~S),~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~Decl.last_query(~S),~render_last,~Fixture.absent_body,~Setup<S>,ready(~S),last_failed(~S),app,"PositionAbsent","Update")
def resource_failed(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit & Decl.First(~S),DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),first_fold(~S)>) -> Setup<S>:
  match app:
    case Build.Registered{world,(_,first),_,_}:ResourceRejected{world,first}
def first_appended(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit & Decl.First(~S),DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),first_fold(~S)>) -> Setup<S>:
  ResourceRegistration.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~(Unit & Decl.First(~S)),~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>>,~Tree.observe_pair(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Projection.Product<C.Access<U32>,Unit>>>>,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaves.component_observe(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first)),~first_fold(~S),~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~U32,~Full.declaration(~S),~Full.body,~Setup<S>,resource_appended(~S),resource_failed(~S),app,"CounterUpdate","Update")
def first_failed(~S:Data,app:Build.Registered<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,Unit,Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),Leaf.empty(~S)>) -> Setup<S>:
  match app:
    case Build.Registered{world,_,_,_}:FirstRejected{world}
def register(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> Setup<S>:
  ComponentRegistration.register(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),~Leaf.empty(~S),~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~S),~render_first,~Bodies.component,~Setup<S>,first_appended(~S),first_failed(~S),Build.empty(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,world),"PositionRead","Update")
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
