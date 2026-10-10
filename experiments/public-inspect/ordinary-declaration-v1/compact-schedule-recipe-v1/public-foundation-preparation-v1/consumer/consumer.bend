import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import ./fixture-full.bend as Full
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import ./frontend.bend as Auto
import ./declarations.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import ./metadata.bend as Metadata
import ./fixture-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Stored
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as Result
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/operational-v1/consumer.bend as ScheduleFixture
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
def rendered(result:Array<U32> & String) -> String:
  match result:
    case (_,text):text
def rendered_flags(result:Array<Bool> & String) -> String:
  match result:
    case (_,text):text
def output(value:Result.Output<Unit,RF.Output>) -> String:
  match value:
    case Result.ComponentOutput{value}:"Component:" ++ List.show(&2,Unit,x=>"Unit",value)
    case Result.ResourceOutput{RF.Output{values}}:"Resource:" ++ rendered(Dump.u32_array(values))
def outputs(values:List<Result.Output<Unit,RF.Output>>) -> String:
  match values:
    case []:"[]"
    case head <> rest:"[" ++ output(head) ++ "]" ++ outputs(rest)
def refused(value:Maybe<Result.Arguments<Unit,Input.Args>>) -> String:
  match value:
    case None{}:"None"
    case Some{Result.ComponentArgs{(_,cursor)}}:"ComponentArgs{cursor=" ++ U32.show(cursor) ++ "}"
    case Some{Result.ResourceArgs{Input.Args{flags}}}:"ResourceArgs{" ++ rendered_flags(Dump.bool_array(flags)) ++ "}"
def world_joined(~S:Data,owners:Decl.Owners(~S),debug:Bool,label:String,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String) -> Auto.RegisteredApplication(~S) & String:
  match result:
    case (world,state):(Build.Registered{world,owners,Tree.Recipe{},debug},label ++ "|world{" ++ state ++ "}")
def owners_joined(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,debug:Bool,label:String,result:Decl.Owners(~S) & List<&2,Stored.Fields<S>>) -> Auto.RegisteredApplication(~S) & String:
  match result:
    case (owners,fields):world_joined(~S,owners,debug,label ++ "|owners=" ++ List.show(&2,Stored.Fields<S>,Fields.fields_text(~S),fields),Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~Fixture.payload,~Dump.u32_array,~U32.show,world))
# Independent test observer: this record read is separate from production debug False.
def observed(~S:Data,app:Auto.RegisteredApplication(~S),label:String) -> Auto.RegisteredApplication(~S) & String:
  match app:
    case Build.Registered{world,owners,_,debug}:owners_joined(~S,world,debug,label,Metadata.observe(~S,owners))
def shown(~S:Data,result:Auto.RegisteredApplication(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Auto.Rows(~S)>>>) -> Auto.RegisteredApplication(~S) & String:
  match result:
    case (app,value):observed(~S,app,Full.debug(~S,~Auto.Rows(~S),value))
def snapshot(~S:Data,flag:Bool,app:Auto.RegisteredApplication(~S)) -> Auto.RegisteredApplication(~S) & String:
  shown(~S,Auto.snapshot(~S,Build.enabled(~S,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~Decl.Owners(~S),~Auto.Rows(~S),~Auto.observe(~S),app,flag)))
def returned(~S:Data,debug:Bool,details:String,result:Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),Result.Error<Q.Error<Unit>,RF.Error>>) -> Auto.RegisteredApplication(~S) & String:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations}:observed(~S,Build.Registered{world,owners,Tree.Recipe{},debug},"Finished{namespace=" ++ U32.show(namespace) ++ "|name=" ++ name ++ "|steps=" ++ List.show(&2,Sch.Step,ScheduleFixture.step,steps) ++ "|observations=" ++ List.show(&2,Sch.Observation,ScheduleFixture.observation,observations) ++ "|" ++ details ++ "}")
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,_,_}:observed(~S,Build.Registered{world,owners,Tree.Recipe{},debug},"Failed|" ++ details)
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}:observed(~S,Build.Registered{world,owners,Tree.Recipe{},debug},"Rejected|" ++ details)
def invoked(~S:Data,result:(Sch.RunResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),Result.Error<Q.Error<Unit>,RF.Error>> & (Maybe<Result.Arguments<Unit,Input.Args>> & List<Result.Output<Unit,RF.Output>>)) & Bool) -> Auto.RegisteredApplication(~S) & String:
  match result:
    case ((run,(args,values)),debug):returned(~S,debug,"refused=" ++ refused(args) ++ "|outputs=" ++ outputs(values),run)
def first_run(~S:Data,app:Auto.RegisteredApplication(~S)) -> Auto.RegisteredApplication(~S) & String:
  invoked(~S,Auto.run(~S,~Auto.condition_first(~S),app))
def second_run(~S:Data,app:Auto.RegisteredApplication(~S)) -> Auto.RegisteredApplication(~S) & String:
  invoked(~S,Auto.run(~S,~Auto.condition_second(~S),app))
def joined(~App:Type,continue:App -> String -> String,result:App & String) -> String:
  match result:
    case (app,text):continue(app,text)
def sequence(~App:Type,actions:List<(App -> App & String)>,prefix:String,app:App) -> String:
  match actions:
    case []:prefix
    case action <> rest:joined(~App,app=>text=>sequence(~App,rest,prefix ++ text ++ "\n",app),action(app))
def registered(~S:Data,result:Auto.Setup<S>) -> String:
  match result:
    case Auto.Ready{app}:sequence(~Auto.RegisteredApplication(~S),[snapshot(~S,True{}),snapshot(~S,True{}),snapshot(~S,False{}),first_run(~S),snapshot(~S,True{}),snapshot(~S,False{}),second_run(~S),snapshot(~S,True{}),snapshot(~S,True{})],"",app)
    case _ :"REGISTRATION_REJECTED"
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
    case W.Created{_,world}:registered(~S,Auto.register(~S,W.enqueue(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,Full.entities(~S,count,True{},world),ScheduleFixture.deferred(~S))))
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.empty_store(~S),W.factory(),Array.new(U32,0n,10)))
type Report is Data:
  Report{empty:String,populated:String}
