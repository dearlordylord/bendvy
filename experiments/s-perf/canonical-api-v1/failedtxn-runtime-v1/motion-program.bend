import Base
import ../../../../src/ecs/system.bend as Sys
import motion-dispose.bend as Dispose
import ../dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-systems.bend as S
import motion-registration.bend as Reg
import motion-schedule.bend as Schedule
import motion-boundary.bend as Boundary
import motion-owner-observe.bend as Observe
import motion-observe.bend as O
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP

type Status is Data:
  Complete{}
  Stopped{reason:String}
type State is Type:
  State{world:F.World(),owners:S.Owners,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status}
def requirement(value:SP.Requirement<T.MotionSchema>) -> String:
  match value:
    case SP.Component{id}:"Component{" ++ U32.show(id) ++ "}"
    case SP.Resource{id}:"Resource{" ++ U32.show(id) ++ "}"
    case SP.Service{id}:"Service{" ++ U32.show(id) ++ "}"
def status(phase:U32,failed:Bool) -> Status:
  match phase failed:
    case 1, True{}:Complete{}
    case 1, False{}:Stopped{"expected B Failure7 was not returned"}
    case _, True{}:Stopped{"unexpected schedule failure"}
    case _, False{}:Complete{}
def phase_frame(iteration:U32,phase:U32,frame:S.Frame) -> S.Frame:
  match phase frame:
    case 1, S.Frame{first,second,_,_,_,_,failed,calls}:S.Frame{first,second,iteration,1,None{},None{},failed,calls}
    case phase, S.Frame{first,second,_,_,pending,retry,failed,calls}:S.Frame{first,second,iteration,phase,pending,retry,failed,calls}
def phase(iteration:U32,phase:U32,state:State) -> State:
  match state:
    case State{world,S.Owners{registered,dispose,frame},ids,namespace,boundaries,schedules,result}:State{world,S.Owners{registered,dispose,phase_frame(iteration,phase,frame)},ids,namespace,boundaries,schedules,result}
def finished(phase:U32,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,requirements:List<&2,SP.Requirement<T.MotionSchema>>,+failed:Bool,observations:List<&2,Sch.Observation>,world:F.World(),schedule:Sch.Schedule<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners>) -> State:
  match schedule:
    case Sch.Schedule{ns,name,steps,owners}:State{world,owners,ids,namespace,boundaries,List.append(&2,String,schedules,["namespace=" ++ U32.show(ns) ++ ";name=" ++ O.audit_effect(name) ++ ";steps=" ++ List.show(&2,Sch.Step,Schedule.step_text,steps) ++ ";requirements=" ++ List.show(&2,SP.Requirement<T.MotionSchema>,requirement,requirements) ++ ";failed=" ++ Bool.show(failed) ++ ";observations=" ++ List.show(&2,Sch.Observation,Schedule.observation,observations)]),status(phase,failed)}
def executed(phase:U32,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,requirements:List<&2,SP.Requirement<T.MotionSchema>>,result:Sch.RunResult<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners,Unit>) -> State:
  match result:
    case Sch.Finished{schedule,world,observations}:finished(phase,ids,namespace,boundaries,schedules,requirements,False{},observations,world,schedule)
    case Sch.Failed{schedule,world,_,observations}:finished(phase,ids,namespace,boundaries,schedules,requirements,True{},observations,world,schedule)
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}:State{world,owners,ids,namespace,boundaries,List.append(&2,String,schedules,["ScheduleRejected"]),Stopped{"schedule rejected"}}
def provisioned(phase:U32,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,result:SP.ProvisionResult<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners,Unit>) -> State:
  match result:
    case SP.Executed{result,requirements}:executed(phase,ids,namespace,boundaries,schedules,requirements,result)
    case SP.Missing{SP.Provisioned{Sch.Schedule{_,_,_,owners},_},world,missing}:State{world,owners,ids,namespace,boundaries,List.append(&2,String,schedules,["Missing=" ++ List.show(&2,SP.Requirement<T.MotionSchema>,requirement,missing)]),Stopped{"missing provision"}}
def dispatch(owners:S.Owners,world:F.World(),target:U32) -> S.Owners & Sys.Outcome<F.World(),Unit,Unit>:S.dispatch(owners,world,target)
def built(phase:U32,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,world:F.World(),result:SP.Build<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners>) -> State:
  match result:
    case SP.Built{schedule}:provisioned(phase,ids,namespace,boundaries,schedules,SP.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Owners,~Unit,~dispatch,~S.condition,~Schedule.provision,schedule,world))
    case SP.Invalid{owners}:State{world,owners,ids,namespace,boundaries,schedules,Stopped{"invalid schedule plan"}}
def run_phase(+phase:U32,state:State) -> State:
  match state:
    case State{world,owners,+ids,+namespace,boundaries,schedules,Complete{}}:built(phase,ids,namespace,boundaries,schedules,world,SP.build(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Owners,namespace,"FailedTxn/phase" ++ U32.show(phase),Schedule.plan(phase,ids),Schedule.ids(ids),owners))
    case state:state
def boundary_returned(dispose:Dispose.Registry(),frame:S.Frame,registered:Reg.Owners,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status,observed:F.World() & Boundary.Boundary) -> State:
  match observed:
    case (world,boundary):State{world,S.Owners{registered,dispose,frame},ids,namespace,List.append(&2,Boundary.Boundary,boundaries,[boundary]),schedules,status}
def boundary_owners(name:String,world:F.World(),dispose:Dispose.Registry(),+frame:S.Frame,ids:Schedule.IDs,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status,observed:Reg.Owners & String) -> State:
  match observed:
    case (registered,text):boundary_returned(dispose,frame,registered,ids,namespace,boundaries,schedules,status,Boundary.run(name,text,frame,world))
def boundary(name:String,state:State) -> State:
  match state:
    case State{world,S.Owners{registered,dispose,frame},ids,namespace,boundaries,schedules,status}:boundary_owners(name,world,dispose,frame,ids,namespace,boundaries,schedules,status,Observe.registered(registered))
def step(+iteration:U32,state:State) -> State:
  boundary("disposed",run_phase(6,phase(iteration,6,boundary("applied-FIFO",run_phase(5,phase(iteration,5,run_phase(4,phase(iteration,4,boundary("retry-before-barrier",run_phase(3,phase(iteration,3,run_phase(2,phase(iteration,2,boundary("failed-before-barrier",run_phase(1,phase(iteration,1,state))))))))))))))))
def loops(fuel:Nat,+iteration:U32,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,U32.add(iteration,1),step(iteration,state))
