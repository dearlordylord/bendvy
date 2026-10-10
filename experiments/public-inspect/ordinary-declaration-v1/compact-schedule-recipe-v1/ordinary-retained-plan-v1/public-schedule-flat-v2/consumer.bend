import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/frontend.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/dispatch.bend as Dispatch
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/unit-adapter.bend as Adapter
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def Application(~S:Data) -> Type:
  Scheduled.Application<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),Front.rows(~S),Front.observe(~S),Front.fold(~S)>
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
def planned(~S:Data,value:Scheduled.PlannedStep<S>) -> String:
  match value:
    case Scheduled.PlannedStep{actual,needs}:step(actual) ++ ":needs=" ++ List.show(&2,SP.Requirement<S>,requirement(~S),needs)
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def description(~S:Data,value:Maybe<&2,Scheduled.Description<S,Front.rows(~S)>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{Scheduled.Description{view,namespace,name,steps}}:F.debug(~S,~Front.rows(~S),Some{view}) ++ "|schedule=" ++ U32.show(namespace) ++ ":" ++ name ++ ":" ++ List.show(&2,Scheduled.PlannedStep<S>,planned(~S),steps)
def plan(~S:Data) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{2,1},[SP.Resource{7}]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{1,2},[SP.Component{8},SP.Resource{7}]}}}}
def completed(~S:Data,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:F.Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,text):(Scheduled.Application{app,plan,namespace,name,steps,needs},text)
def complete(~S:Data,text:String,value:Application(~S)) -> Application(~S) & String:
  match value:
    case Scheduled.Application{app,plan,namespace,name,steps,needs}:completed(~S,plan,namespace,name,steps,needs,F.complete(~S,text,app))
def observed(~S:Data,result:Application(~S) & Maybe<&2,Scheduled.Description<S,Front.rows(~S)>>) -> Application(~S) & String:
  match result:
    case (app,view):complete(~S,description(~S,view),app)
def snapshot(~S:Data,enabled:Bool,value:Application(~S)) -> Application(~S) & String:
  observed(~S,Scheduled.snapshot(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),Scheduled.enabled(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),value,enabled)))
def increment_observed(values:Array<U32> & U32) -> Array<U32> & Unit:
  match values:
    case (values,prior):(Array.set(U32,values,0,U32.add(prior,1)),Unit{})
def increment(values:Array<U32>) -> Array<U32> & Unit:
  increment_observed(Array.get(U32,values,0))
def condition_returned(~S:Data,+first:Bool,+id:U32,result:F.World(~S) & Unit) -> F.World(~S) & Bool:
  match result:
    case (world,_):(world,Bool.or(Bool.and(first,U32.is_eq(id,1)),Bool.and(Bool.not(first),U32.is_eq(id,2))))
def resource_incremented(unit:Unit,result:Array<U32> & Unit) -> Setup.resources(~Array<U32>) & Unit:
  match result:
    case (values,_):(Product.Owner{unit,values},Unit{})
def resource_increment(resource:Setup.resources(~Array<U32>)) -> Setup.resources(~Array<U32>) & Unit:
  match resource:
    case Product.Owner{unit,values}:resource_incremented(unit,increment(values))
def condition(~S:Data,+first:Bool,world:F.World(~S),id:U32) -> F.World(~S) & Bool:
  condition_returned(~S,first,id,W.observe_resource(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Unit,~resource_increment,world))
def refused_text(value:Maybe<D.Arguments<Unit,Unit>>) -> String:
  match value:
    case None{}:"None"
    case Some{D.ComponentArgs{(_,cursor)}}:"ComponentUnit:" ++ U32.show(cursor)
    case Some{D.ResourceArgs{_}}:"ResourceUnit"
def run_returned(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,plan:SP.Plan<S>,debug:Bool,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Error<Q.Error<Unit>,Front.Error>> & Maybe<D.Arguments<Unit,Unit>>) -> Application(~S) & String:
  match result:
    case (Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations},refused):complete(~S,"Finished:" ++ List.show(&2,Sch.Observation,observation,observations) ++ ":refused=" ++ refused_text(refused),Scheduled.Application{App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},debug}},plan,namespace,name,steps,needs})
    case (Sch.Failed{Sch.Schedule{namespace,name,steps,owners},world,error,observations},refused):complete(~S,"Failed:" ++ List.show(&2,Sch.Observation,observation,observations) ++ ":refused=" ++ refused_text(refused),Scheduled.Application{App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},debug}},plan,namespace,name,steps,needs})
    case (Sch.Rejected{Sch.Schedule{namespace,name,steps,owners},world},refused):complete(~S,"Rejected:refused=" ++ refused_text(refused),Scheduled.Application{App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},debug}},plan,namespace,name,steps,needs})
def lifted_returned(~S:Data,refused:Maybe<D.Arguments<Unit,Unit>>,result:Front.owners(~S) & List<&2,Records.Fields<S>>) -> Adapter.Owners<Front.owners(~S)> & List<&2,Records.Fields<S>>:
  match result:
    case (registered,fields):(Adapter.Owners{registered,refused},fields)
def lift_fold(~S:Data,owners:Adapter.Owners<Front.owners(~S)>) -> Adapter.Owners<Front.owners(~S)> & List<&2,Records.Fields<S>>:
  match owners:
    case Adapter.Owners{registered,refused}:lifted_returned(~S,refused,Front.fold(~S,registered))
def provision(~S:Data,world:F.World(~S)) -> F.World(~S) & List<&2,SP.Requirement<S>>:
  (world,[SP.Resource{7},SP.Component{8}])
def Lifted(~S:Data) -> Type:
  Scheduled.Application<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Adapter.Owners<Front.owners(~S)>,Front.rows(~S),Front.observe(~S),lift_fold(~S)>
def finished_app(~S:Data,value:Lifted(~S),observations:List<&2,Sch.Observation>) -> Application(~S) & String:
  match value:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:run_returned(~S,schema,plan,debug,needs,Adapter.finished(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Q.Error<Unit>,~Front.Error,namespace,name,steps,world,observations,owners))
def failed_app(~S:Data,value:Lifted(~S),error:Maybe<&2,D.Error<Q.Error<Unit>,Front.Error>>,observations:List<&2,Sch.Observation>) -> Application(~S) & String:
  match value:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:run_returned(~S,schema,plan,debug,needs,Adapter.failed(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Q.Error<Unit>,~Front.Error,error,namespace,name,steps,world,observations,owners))
def rejected_app(~S:Data,value:Lifted(~S)) -> Application(~S) & String:
  match value:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:run_returned(~S,schema,plan,debug,needs,Adapter.rejected(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Q.Error<Unit>,~Front.Error,namespace,name,steps,world,owners))
def missing_app(~S:Data,value:Lifted(~S),missing:List<&2,SP.Requirement<S>>) -> Application(~S) & String:
  match value:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,Adapter.Owners{owners,refused},recipe,debug}},plan,namespace,name,steps,needs}:complete(~S,"Missing:" ++ List.show(&2,SP.Requirement<S>,requirement(~S),missing),Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs})
def scheduled_returned(~S:Data,result:Scheduled.RunResult<Lifted(~S),S,Maybe<&2,D.Error<Q.Error<Unit>,Front.Error>>>) -> Application(~S) & String:
  match result:
    case Scheduled.Finished{app,observations}:finished_app(~S,app,observations)
    case Scheduled.Failed{app,error,observations}:failed_app(~S,app,error,observations)
    case Scheduled.Rejected{app}:rejected_app(~S,app)
    case Scheduled.Missing{app,missing}:missing_app(~S,app,missing)
def run(~S:Data,~first:Bool,value:Application(~S)) -> Application(~S) & String:
  match value:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}:scheduled_returned(~S,Scheduled.run(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Adapter.Owners<Front.owners(~S)>,~Front.rows(~S),~Front.observe(~S),~lift_fold(~S),~Maybe<&2,D.Error<Q.Error<Unit>,Front.Error>>,~Adapter.dispatch(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Q.Error<Unit>,~Front.Error,~Dispatch.dispatch(~S)),~condition(~S,first),~provision(~S),Scheduled.Application{App.Application{schema,Build.Registered{world,Adapter.Owners{owners,None{}},recipe,debug}},plan,namespace,name,steps,needs}))
def joined(~Value:Type,next:Value -> String -> String,result:Value & String) -> String:
  match result:
    case (value,text):next(value,text)
def sequence(~Value:Type,actions:List<(Value -> Value & String)>,prefix:String,value:Value) -> String:
  match actions:
    case []:prefix
    case action <> rest:joined(~Value,next=>text=>sequence(~Value,rest,prefix ++ text ++ "\n",next),action(value))
def attached(~S:Data,result:Scheduled.Attachment<F.Application(~S),Application(~S)>) -> String:
  match result:
    case Scheduled.Attached{app}:sequence(~Application(~S),[snapshot(~S,True{}),snapshot(~S,True{}),snapshot(~S,False{}),run(~S,~True{}),snapshot(~S,True{}),run(~S,~False{}),snapshot(~S,True{}),snapshot(~S,False{}),snapshot(~S,True{})],"",app)
    case Scheduled.Invalid{app}:"INVALID_PLAN"
def registered(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,result:Front.SetupResult<S>) -> String:
  match result:
    case Front.Ready{app}:attached(~S,Scheduled.attach(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),App.attached(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),schema,app),"UpdateSchedule",plan(~S)))
    case _:"REGISTRATION_REJECTED"
def created(~S:Data,count:Nat,result:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> String:
  match result:
    case (schema,W.Created{_,world}):registered(~S,schema,Front.register(~S,W.enqueue(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,F.entities(~S,count,True{},world),F.pending(~S))))
    case _:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,App.create(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~F.empty_store(~S),Setup.schema(~S,~Array<U32>,~Array<U32>,Front.declarations(~S)),W.factory(),Product.Owner{Unit{},Array.new(U32,0n,10)}))
type Report is Data:
  Report{empty:String,populated:String}
