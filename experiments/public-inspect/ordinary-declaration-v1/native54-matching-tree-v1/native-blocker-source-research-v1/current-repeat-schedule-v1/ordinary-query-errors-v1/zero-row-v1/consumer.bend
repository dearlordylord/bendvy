import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-leaf-run.bend as LeafRun
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import ../../ordinary-app-v1/observation.bend as Old
import ./query-observation.bend as Inspect
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-population-v1/frontend-public.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-population-v1/setup-public.bend as Setup
type A is Data:
  A{}
type Other is Data:
  Other{}
def Application(~S:Data) -> Type:
  Scheduled.Application<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),Front.rows(~S),Front.observe(~S),Front.fold(~S)>
def condition(~S:Data,world:Old.World(~S),_:U32) -> Old.World(~S) & Bool:(world,True{})
def provision(~S:Data,world:Old.World(~S)) -> Old.World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def returned(~S:Data,rest:Unit,right:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,result:Run.TransportResult<S,Old.World(~S),Unit & U32,Q.Error<Unit>,List<&2,Unit>,Records.Token<Front.ComponentRegistry(~S)>>) -> Front.owners(~S) & Sys.Outcome<Old.World(~S),Q.Error<Unit>,Unit>:
  match result:
    case Run.Completed{token,fields,Sys.Succeeded{world,_}}:(((rest,Leaf.Record{token,fields}),right),Sys.Succeeded{world,Unit{}})
    case Run.Completed{token,fields,Sys.Failed{world,error}}:(((rest,Leaf.Record{token,fields}),right),Sys.Failed{world,error})
    case Run.RegistrationRejected{token,fields,world,_}:(((rest,Leaf.Record{token,fields}),right),Sys.Failed{world,Q.UserError{Unit{}}})
def dispatch(~S:Data,owners:Front.owners(~S),world:Old.World(~S),_:U32) -> Front.owners(~S) & Sys.Outcome<Old.World(~S),Q.Error<Unit>,Unit>:
  match owners:
    case ((rest,Leaf.Record{token,+fields}),right):returned(~S,rest,right,Run.run(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~(Unit & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.component_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,C.Access<U32>>,~Front.query(~S),~Front.component_body),token,fields,world,(Unit{},LeafRun.current_cursor(~S,fields))))
def described(~S:Data,plan:SP.Plan<S>,ns:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:Old.Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,text):(Scheduled.Application{app,plan,ns,name,steps,needs},text)
def snapshot(~S:Data,value:Application(~S)) -> Application(~S) & String:
  match value:
    case Scheduled.Application{app,plan,ns,name,steps,needs}:described(~S,plan,ns,name,steps,needs,Inspect.describe(~S,app))
def show_observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied{}"
def ran(~S:Data,result:Scheduled.RunResult<Application(~S),S,Q.Error<Unit>>) -> Application(~S) & String:
  match result:
    case Scheduled.Finished{app,observations}:(app,"Finished:" ++ List.show(&2,Sch.Observation,show_observation,observations))
    case Scheduled.Failed{app,_,observations}:(app,"Failed:" ++ List.show(&2,Sch.Observation,show_observation,observations))
    case Scheduled.Rejected{app}:(app,"Rejected")
    case Scheduled.Missing{app,_}:(app,"Missing")
def run(~S:Data,app:Application(~S)) -> Application(~S) & String:
  ran(~S,Scheduled.run(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),~Q.Error<Unit>,~dispatch(~S),~condition(~S),~provision(~S),app))
def joined(~S:Data,next:Application(~S) -> String -> Application(~S) & String,result:Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,text):next(app,text)
def sequence(~S:Data,actions:List<(Application(~S) -> Application(~S) & String)>,prefix:String,app:Application(~S)) -> Application(~S) & String:
  match actions:
    case []:(app,prefix)
    case action <> rest:joined(~S,next=>text=>sequence(~S,rest,prefix ++ text ++ "\n",next),action(app))
def detached(~S:Data,result:Application(~S) & String) -> String:
  match result:
    case (_,text):text
def attached(~S:Data,result:Scheduled.Attachment<Old.Application(~S),Application(~S)>) -> String:
  match result:
    case Scheduled.Invalid{_}:"ATTACH_INVALID"
    case Scheduled.Attached{app}:detached(~S,sequence(~S,[snapshot(~S),snapshot(~S),run(~S),snapshot(~S),snapshot(~S),run(~S),snapshot(~S),snapshot(~S)],"",app))
def registered(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,result:Front.SetupResult<S>) -> String:
  match result:
    case Front.Ready{app}:attached(~S,Scheduled.attach(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),App.attached(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),schema,app),"InspectApp",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Entry{Sch.System{1,1},[]}}))
    case _:"REGISTER_REFUSED"
def created(~S:Data,result:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> String:
  match result:
    case (schema,W.Created{_,world}):registered(~S,schema,Front.register(~S,W.enqueue(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,Old.entities(~S,2n,True{},world),Old.pending(~S))))
    case _:"CREATE_REFUSED"
def scenario(~S:Data) -> String:
  created(~S,App.create(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Old.empty_store(~S),Setup.schema(~S,~Array<U32>,~Array<U32>,Front.declarations(~S)),W.factory(),Product.Owner{Unit{},Product.Owner{Unit{},Array.new(U32,0n,10)}}))
def main() -> String:"A\n" ++ scenario(~A) ++ "Other\n" ++ scenario(~Other)
