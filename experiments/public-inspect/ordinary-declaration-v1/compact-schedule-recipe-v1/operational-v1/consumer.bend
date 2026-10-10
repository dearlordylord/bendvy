import Base
import ./unit-bodies.bend as Bodies
import ./finite-adapter.bend as Adapter
import ./dispatch-result.bend as DResult
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import ./bridge.bend as B
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Full
import ./ordinary-unit.bend as Ordinary
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as ResourceFixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as Result
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-observation-v1/schedule.bend as P
def incremented(amount:U32,result:Array<U32> & U32) -> Array<U32> & Unit:
  match result:
    case (values,prior):(Array.set(U32,values,0,U32.add(prior,amount)),Unit{})
def increment(amount:U32,values:Array<U32>) -> Array<U32> & Unit:
  incremented(amount,Array.get(U32,values,0))
def condition_world(~S:Data,+id:U32,+first:Bool,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Unit) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool:
  match result:
    case (world,_):(world,Bool.or(Bool.and(first,U32.is_eq(id,1)),Bool.and(Bool.not(first),U32.is_eq(id,2))))
def first_condition(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool:
  condition_world(~S,id,True{},W.observe_resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~increment(1),world))
def second_condition(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Bool:
  condition_world(~S,id,False{},W.observe_resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~increment(1),world))
def deferred_result(~S:Data,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & Unit) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match result:
    case (world,_):world
def deferred(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  deferred_result(~S,W.observe_resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Unit,~increment(100),world))
def available(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & List<&2,SP.Requirement<S>>:
  (world,[SP.Resource{7}])
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def step(value:Sch.Step) -> String:
  match value:
    case Sch.Phase{name}:"Phase:" ++ name
    case Sch.System{id,condition}:"System:" ++ U32.show(id) ++ ":condition=" ++ U32.show(condition)
    case Sch.Barrier{}:"Barrier"
def requirement(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Component{id}:"Component:" ++ U32.show(id)
    case SP.Resource{id}:"Resource:" ++ U32.show(id)
    case SP.Service{id}:"Service:" ++ U32.show(id)
def planned(~S:Data,value:P.PlannedStep<S>) -> String:
  match value:
    case P.PlannedStep{entry,needs}:step(entry) ++ ":" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs)
def plan(~S:Data,ids:List<&2,U32>) -> SP.Plan<S>:
  match ids:
    case one <> two <> _:SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{one,1},[SP.Resource{7}]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{two,2},[SP.Resource{7},SP.Resource{7}]}}}}
    case _:SP.Entry{Sch.System{999,0},[]}
def described(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,value:Maybe<&2,DTO.Product<DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>,B.ScheduleDescription<S>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{DTO.Product{rows,B.ScheduleDescription{namespace,name,steps,systems}}}:Full.debug(~S,~Rows,Some{rows}) ++ "|schedule=" ++ U32.show(namespace) ++ ":" ++ name ++ ":" ++ List.show(&2,P.PlannedStep<S>,planned(~S),steps) ++ ":" ++ List.show(&2,DTO.Binding<S>,Full.binding(~S),systems)
def restored(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & String) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case (Compact.Application{world,owners,recipe,debug},text):(B.Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug},text)
def observed(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,value:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match value:
    case B.Application{world,operational,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug}:restored(~S,~H,~Rows,~Recipes,operational,namespace,name,steps,needs,Full.observed(~S,~H,~Rows,~Recipes,Compact.Application{world,owners,recipe,debug}))
def shown_state(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,label:String,result:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case (app,text):(app,label ++ "|" ++ text)
def shown_row(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,result:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & Maybe<&2,DTO.Product<DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>,B.ScheduleDescription<S>>>) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case (app,value):shown_state(~S,~H,~Rows,~Recipes,described(~S,~H,~Rows,~Recipes,value),observed(~S,~H,~Rows,~Recipes,app))
def shown(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,snapshot:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>,app:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>,enabled:Bool) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  shown_row(~S,~H,~Rows,~Recipes,B.snapshot(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~Recipes,snapshot,B.enable_debug(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~Recipes,app,enabled)))
def sequence_join(~App:Type,next:App -> String -> String,prefix:String,result:App & String) -> String:
  match result:
    case (app,text):next(app,prefix ++ text ++ "\n")
def sequence(~App:Type,steps:List<(App -> App & String)>,prefix:String,app:App) -> String:
  match steps:
    case []:prefix
    case step <> rest:sequence_join(~App,app=>text=>sequence(~App,rest,text,app),prefix,step(app))
def run_state(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,label:String,result:Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>>,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,recipe:Recipes,debug:Bool) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case Sch.Finished{schedule,world,observations}:shown_state(~S,~H,~Rows,~Recipes,label ++ ":Finished:" ++ List.show(&2,Sch.Observation,observation,observations),observed(~S,~H,~Rows,~Recipes,B.Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug}))
    case Sch.Failed{schedule,world,error,observations}:shown_state(~S,~H,~Rows,~Recipes,label ++ ":Failed:" ++ List.show(&2,Sch.Observation,observation,observations),observed(~S,~H,~Rows,~Recipes,B.Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug}))
    case Sch.Rejected{schedule,world}:shown_state(~S,~H,~Rows,~Recipes,label ++ ":Rejected",observed(~S,~H,~Rows,~Recipes,B.Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug}))
def provision_result(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,label:String,plan:SP.Plan<S>,recipe:Recipes,debug:Bool,result:SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>>) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case SP.Executed{result,needs}:run_state(~S,~H,~Rows,~Recipes,label,result,plan,needs,recipe,debug)
    case SP.Missing{schedule,world,missing}:shown_state(~S,~H,~Rows,~Recipes,label ++ ":MissingProvision",observed(~S,~H,~Rows,~Recipes,B.Application{world,plan,schedule,recipe,debug}))
def run_returned(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,label:String,plan:SP.Plan<S>,recipe:Recipes,debug:Bool,result:SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match result:
    case (result,refused):provision_result(~S,~H,~Rows,~Recipes,label,plan,recipe,debug,result)
def executed(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,run:SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>,label:String,app:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>) -> B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes> & String:
  match app:
    case B.Application{world,plan,schedule,recipe,debug}:run_returned(~S,~H,~Rows,~Recipes,label,plan,recipe,debug,run(schedule,world))
def observe_snapshots(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,firstRun:SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>,secondRun:SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>,snapshots:List<(Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>)>,app:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>) -> String:
  match snapshots:
    case first <> second <> third <> fourth <> fifth <> sixth <> seventh <> _ :sequence(~B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>,[
      app=>shown(~S,~H,~Rows,~Recipes,first,app,True{}),
      app=>shown(~S,~H,~Rows,~Recipes,second,app,False{}),
      app=>shown(~S,~H,~Rows,~Recipes,third,app,True{}),
      app=>executed(~S,~H,~Rows,~Recipes,firstRun,"FirstRun",app),
      app=>shown(~S,~H,~Rows,~Recipes,fourth,app,True{}),
      app=>executed(~S,~H,~Rows,~Recipes,secondRun,"SecondRun",app),
      app=>shown(~S,~H,~Rows,~Recipes,fifth,app,True{}),
      app=>shown(~S,~H,~Rows,~Recipes,sixth,app,False{}),
      app=>shown(~S,~H,~Rows,~Recipes,seventh,app,True{})],"",app)
    case _:"SNAPSHOT_CALLBACKS_MISSING"
def observe_steps(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,runs:List<(SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>)>,snapshots:List<(Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>)>,app:B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>) -> String:
  match runs:
    case firstRun <> secondRun <> _:observe_snapshots(~S,~H,~Rows,~Recipes,firstRun,secondRun,snapshots,app)
    case _:"RUN_CALLBACKS_MISSING"
def attached(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,runs:List<(SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>)>,snapshots:List<(Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>)>,result:DTO.Registration<Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>,B.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,Recipes>>) -> String:
  match result:
    case DTO.Failed{app}:"ATTACH_REJECTED"
    case DTO.Registered{app}:observe_steps(~S,~H,~Rows,~Recipes,runs,snapshots,app)
def registered_cataloged(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,runs:List<(SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>)>,snapshots:List<(Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>)>,owners:H,recipe:Recipes,debug:Bool,observed:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & (U32 & List<&2,U32>)) -> String:
  match observed:
    case (world,(_,ids)):attached(~S,~H,~Rows,~Recipes,runs,snapshots,B.attach(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~Recipes,Compact.Application{world,owners,recipe,debug},"Main",plan(~S,ids)))

def registered(~S:Data,~H:Type,~Rows:Data,~Recipes:Type,~snapshot:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> -> Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>,runs:List<(SP.Provisioned<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> SP.ProvisionResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,DResult.Error<Q.Error<Unit>,Unit>> & Maybe<DResult.Arguments<Unit,Unit>>)>,app:Compact.Application<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,H,Rows,Recipes>) -> String:
  match app:
    case Compact.Application{world,owners,recipe,debug}:registered_cataloged(~S,~H,~Rows,~Recipes,runs,[snapshot,snapshot,snapshot,snapshot,snapshot,snapshot,snapshot],owners,recipe,debug,B.catalog(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,world))
def register(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  Ordinary.register_unit_component_resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S),~Bodies.component,~D.write_ops(~Array<U32>,~U32),~Unit,~U32,~Full.declaration(~S),~Bodies.resource,~first_condition(~S),~second_condition(~S),~available(~S),~String,~registered(~S),~Full.rejected(~S),world,"PositionRead","Update","CounterUpdate","Update")
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  match result:
    case W.Created{_,world}:register(~S,W.enqueue(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,Full.entities(~S,count,True{},world),deferred(~S)))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.empty_store(~S),W.factory(),Array.new(U32,0n,10)))

type Report is Data:
  Report{empty:String,populated:String}
