import ../metadata.bend as M
import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ./owner-observation.bend as Owner
import ./registered-identity.bend as Identity
# The callable never runs: actual registration/schedule ownership is retained.
type Error is Data:
  Error{}
def body(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,args:Unit) -> Sys.Outcome<W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,Error,Unit>:
  Sys.Succeeded{world,args}
def read_join(result:Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation:
  match result:
    case (Check.Frame{world},observation):(world,observation)
def read(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation:
  read_join(Check.resource_read(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Owner.Observation,~Owner.project,Check.Frame{world}))
type Registry is Type:
  Registry{owner:Sys.Registry<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
type Prepared is Type:
  Prepared{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,schedule:Schedule.Schedule<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>}
  RegistrationFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>}
  ScheduleFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,owner:Registry}
def built(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,result:Schedule.Build<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>) -> Prepared:
  match result:
    case Schedule.Built{schedule}:Prepared{world,schedule}
    case Schedule.Invalid{owner}:ScheduleFailed{world,owner}
def identity_join(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,result:Sys.Registry<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & Identity.Identity) -> Prepared:
  match result:
    case (owner,Identity.Identity{namespace,+id}):built(world,Schedule.build(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Registry,namespace,"main",[Schedule.Barrier{},Schedule.System{id,0},Schedule.Phase{"applyStateTransitions"}],[id],Registry{owner}))
def registered(result:Sys.RegistrationResult<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>) -> Prepared:
  match result:
    case Sys.RegistrationFailed{world}:RegistrationFailed{world}
    case Sys.Registered{world,owner}:identity_join(world,Identity.observe(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,owner))
def prepare(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> Prepared:
  registered(Sys.register(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,world,"Inspect",[]))
# Steps are projected from the actual built schedule; every marker advances its
# index. The closed definition maps Phase(applyStateTransitions) explicitly.
type StepView is Data:
  StepView{steps:List<&2,M.Step>,positions:List<&2,String>,valid:Bool}
def system_step(valid:Bool,+name:String,index:Nat,tail:StepView) -> StepView:
  match tail:
    case StepView{steps,positions,ok}:StepView{M.Run{"Inspect"}<>steps,(name++"#"++Nat.show(index))<>positions,Bool.and(valid,ok)}
def deferred_step(tail:StepView) -> StepView:
  match tail:
    case StepView{steps,positions,ok}:StepView{M.ApplyDeferred{}<>steps,positions,ok}
def transition_step(valid:Bool,tail:StepView) -> StepView:
  match tail:
    case StepView{steps,positions,ok}:StepView{M.ApplyStateTransitions{[]}<>steps,positions,Bool.and(valid,ok)}
def steps(input:List<&2,Schedule.Step>,+actual:U32,+name:String,+index:Nat) -> StepView:
  match input:
    case []:StepView{[],[],True{}}
    case Schedule.Barrier{}<>tail:deferred_step(steps(tail,actual,name,Succ{index}))
    case Schedule.Phase{marker}<>tail:transition_step(String.eq(marker,"applyStateTransitions"),steps(tail,actual,name,Succ{index}))
    case Schedule.System{id,condition}<>tail:system_step(Bool.and(U32.is_eq(id,actual),U32.is_eq(condition,0)),name,index,steps(tail,actual,name,Succ{index}))
type View is Data:
  View{schedule:M.Schedule,positions:List<&2,String>,valid:Bool,namespace:U32,id:U32,cursor:U32}
def view_join(schedule:Schedule.Schedule<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>,name:String,namespace:U32,id:U32,cursor:U32,namespaceOK:Bool,observed:StepView) -> Schedule.Schedule<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry> & View:
  match observed:
    case StepView{steps,positions,valid}:(schedule,View{M.Schedule{name,steps},positions,Bool.and(namespaceOK,valid),namespace,id,cursor})
def view(schedule:Schedule.Schedule<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>) -> Schedule.Schedule<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry> & View:
  match schedule:
    case Schedule.Schedule{+namespace,+name,+input,Registry{Sys.Registry{+ownerNamespace,+id,systemName,access,+cursor}}}:view_join(Schedule.Schedule{namespace,name,input,Registry{Sys.Registry{ownerNamespace,id,systemName,access,cursor}}},name,namespace,id,cursor,U32.is_eq(namespace,ownerNamespace),steps(input,id,name,Zero{}))
