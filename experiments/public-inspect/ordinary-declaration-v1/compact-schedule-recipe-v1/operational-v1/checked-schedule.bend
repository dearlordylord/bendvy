import Base
import ./dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

# Private checked transport preserves a refused system's affine arguments.
# Successful outputs are retained in reverse execution order.
type RunResult<S:Data,C:Type,R:Type,E:Data,H:Type,Args:Type,Error:Data,Out:Type> is Type:
  Finished{schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,outputs:List<Out>}
  Failed{schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,error:Error,observations:List<&2,Sch.Observation>,outputs:List<Out>}
  RegistrationRejected{schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,args:Args,observations:List<&2,Sch.Observation>,outputs:List<Out>}
  UnknownSystem{schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,id:U32,observations:List<&2,Sch.Observation>,outputs:List<Out>}
  Rejected{schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>}
  Missing{schedule:SP.Provisioned<S,C,R,E,H>,world:W.World<S,C,R,E>,requirements:List<&2,SP.Requirement<S>>}

def completed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,next:H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> List<Out> -> RunResult<S,C,R,E,H,Args,Error,Out>,owners:H,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,outputs:List<Out>,+id:U32,outcome:Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match outcome:
    case Sys.Succeeded{world,out}:next(owners,world,List.append(&2,Sch.Observation,observations,[Sch.Ran{id}]),out <> outputs)
    case Sys.Failed{world,error}:Failed{Sch.Schedule{namespace,name,all,owners},world,error,List.append(&2,Sch.Observation,observations,[Sch.Ran{id}]),outputs}
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,next:H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> List<Out> -> RunResult<S,C,R,E,H,Args,Error,Out>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,outputs:List<Out>,+id:U32,result:D.DispatchResult<S,C,R,E,H,Args,Error,Out>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match result:
    case D.Completed{owners,outcome}:completed(~S,~C,~R,~E,~H,~Args,~Error,~Out,next,owners,namespace,name,all,observations,outputs,id,outcome)
    case D.RegistrationRejected{owners,world,args}:RegistrationRejected{Sch.Schedule{namespace,name,all,owners},world,args,observations,outputs}
    case D.UnknownSystem{owners,world,actual}:UnknownSystem{Sch.Schedule{namespace,name,all,owners},world,actual,observations,outputs}
def conditioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,next:H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> List<Out> -> RunResult<S,C,R,E,H,Args,Error,Out>,allowed:Bool,owners:H,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,outputs:List<Out>,+id:U32) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match allowed:
    case False{}:next(owners,world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]),outputs)
    case True{}:dispatched(~S,~C,~R,~E,~H,~Args,~Error,~Out,next,namespace,name,all,observations,outputs,id,dispatch(owners,world,id))
def condition_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,next:H -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> List<Out> -> RunResult<S,C,R,E,H,Args,Error,Out>,owners:H,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,outputs:List<Out>,+id:U32,checked:W.World<S,C,R,E> & Bool) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match checked:
    case (world,allowed):conditioned(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,next,allowed,owners,world,namespace,name,all,observations,outputs,id)
def execute(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,steps:List<&2,Sch.Step>,owners:H,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,outputs:List<Out>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match steps:
    case []:Finished{Sch.Schedule{namespace,name,all,owners},world,observations,outputs}
    case Sch.Phase{phase} <> rest:execute(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,rest,owners,world,namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]),outputs)
    case Sch.Barrier{} <> rest:execute(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,rest,owners,W.barrier(~S,~C,~R,~E,world),namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Applied{}]),outputs)
    case Sch.System{+id,slot} <> rest:condition_returned(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,h=>w=>obs=>outs=>execute(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,rest,h,w,namespace,name,all,obs,outs),owners,namespace,name,all,observations,outputs,id,condition(world,slot))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,matches:Bool,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match matches schedule:
    case False{} schedule:Rejected{schedule,world}
    case True{} Sch.Schedule{+namespace,+name,+steps,owners}:execute(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,steps,owners,world,namespace,name,steps,[],[])
def namespace_schedule(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,world:W.World<S,C,R,E>,actual:U32,schedule:Sch.Schedule<S,C,R,E,H>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match schedule:
    case Sch.Schedule{+namespace,name,steps,owners}:allowed(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,U32.is_eq(namespace,actual),Sch.Schedule{namespace,name,steps,owners},world)
def namespace_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule:Sch.Schedule<S,C,R,E,H>,observed:W.World<S,C,R,E> & U32) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match observed:
    case (world,actual):namespace_schedule(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,world,actual,schedule)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  namespace_returned(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,schedule,W.namespace(~S,~C,~R,~E,world))
def requirements_checked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,missing:List<&2,SP.Requirement<S>>,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>,needs:List<&2,SP.Requirement<S>>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match missing:
    case first <> rest:Missing{SP.Provisioned{schedule,needs},world,first <> rest}
    case []:run(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,schedule,world)
def provision_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule:Sch.Schedule<S,C,R,E,H>,+needs:List<&2,SP.Requirement<S>>,observed:W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match observed:
    case (world,available):requirements_checked(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,SP.missing_requirements(~S,needs,available),schedule,world,needs)
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~dispatch:H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,Args,Error,Out>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:SP.Provisioned<S,C,R,E,H>,world:W.World<S,C,R,E>) -> RunResult<S,C,R,E,H,Args,Error,Out>:
  match value:
    case SP.Provisioned{schedule,needs}:provision_returned(~S,~C,~R,~E,~H,~Args,~Error,~Out,~dispatch,~condition,schedule,needs,provision(world))
