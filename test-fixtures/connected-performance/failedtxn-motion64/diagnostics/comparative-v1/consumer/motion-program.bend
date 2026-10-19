import Base
import ../../../method/method.bend as Method
import ../../../method/json.bend as J
import ../method/capture-call.bend as Capture
import ../method/capture-state.bend as CaptureState
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/motion.bend as F
import motion-systems.bend as S
import motion-boundary.bend as Boundary
import ../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../src/ecs/schedule-provision.bend as SP

import motion-app.bend as EntryApp
import ../../../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../../../src/ecs/ordinary-app-execution.bend as Execute
type Status is Data:
  Complete{}
  Stopped{reason:String}
type State is Type:
  State{app:EntryApp.Slot(),namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,status:Status}
def status(phase:U32,failed:Bool) -> Status:
  match phase failed:
    case 1, True{}:Complete{}
    case 1, False{}:Stopped{"expected B Failure7 was not returned"}
    case _, True{}:Stopped{"unexpected schedule failure"}
    case _, False{}:Complete{}
def phase_frame(iteration:U32,phase:U32,frame:S.Frame) -> S.Frame:
  match phase frame:
    case 1, S.Frame{first,second,_,_,_,_,failed,publicCalls,method}:S.Frame{first,second,iteration,1,None{},None{},failed,publicCalls,method}
    case phase, S.Frame{first,second,_,_,pending,retry,failed,publicCalls,method}:S.Frame{first,second,iteration,phase,pending,retry,failed,publicCalls,method}
def update_frame(value:S.Runtime(),args:U32 & U32) -> S.Runtime():
  match value args:
    case (owners,S.Shared{meta,tick,frame}),(iteration,phase):(owners,S.Shared{meta,tick,phase_frame(iteration,phase,frame)})
def phase_slot(iteration:U32,phase:U32,slot:EntryApp.Slot()) -> EntryApp.Slot():
  match slot:
    case Single.Attached{app}:Single.Attached{EntryApp.update(~(U32 & U32),~update_frame,app,(iteration,phase))}
    case slot:slot
def phase(iteration:U32,phase:U32,state:State) -> State:
  match state:
    case State{app,namespace,boundaries,schedules,result}:State{phase_slot(iteration,phase,app),namespace,boundaries,schedules,result}
def start(world:F.World(),owners:S.Owners,namespace:U32) -> State:State{EntryApp.create(world,S.pack(owners)),namespace,[],[],Complete{}}
def phase_outcome(failed:Bool) -> String:
  match failed:
    case True{}:"Failure"
    case False{}:"Success"
def phase_record_frame(frame:S.Frame,failed:Bool) -> S.Frame:
  match frame:
    case S.Frame{first,second,+i,+phase,pending,retry,allFailed,publicCalls,method}:S.Frame{first,second,i,phase,pending,retry,allFailed,publicCalls,Method.append(method,J.object([J.Field{"kind",J.Text{"Phase"}},J.Field{"phase",Method.number(phase)},J.Field{"iteration",Capture.iteration(phase,i)},J.Field{"outcome",J.object([J.Field{"kind",J.Text{phase_outcome(failed)}}])}]))}
def phase_record(value:S.Runtime(),failed:Bool) -> S.Runtime():
  match value:
    case (owners,S.Shared{meta,tick,+frame}):(owners,S.Shared{meta,tick,phase_record_frame(frame,failed)})
def requirement(value:SP.Requirement<T.MotionSchema>) -> J.Value:
  match value:
    case SP.Component{id}:J.object([J.Field{"kind",J.Text{"Component"}},J.Field{"id",Method.number(id)}])
    case SP.Resource{id}:J.object([J.Field{"kind",J.Text{"Resource"}},J.Field{"id",Method.number(id)}])
    case SP.Service{id}:J.object([J.Field{"kind",J.Text{"Service"}},J.Field{"id",Method.number(id)}])
def schedule_step(value:Sch.Step) -> J.Value:
  match value:
    case Sch.System{id,condition}:J.object([J.Field{"kind",J.Text{"System"}},J.Field{"id",Method.number(id)},J.Field{"condition",Method.number(condition)}])
    case Sch.Phase{name}:J.object([J.Field{"kind",J.Text{"Phase"}},J.Field{"name",J.Text{name}}])
    case Sch.Barrier{}:J.object([J.Field{"kind",J.Text{"Barrier"}}])
def observation(value:Sch.Observation) -> J.Value:
  match value:
    case Sch.Entered{name}:J.object([J.Field{"kind",J.Text{"Entered"}},J.Field{"name",J.Text{name}}])
    case Sch.Ran{id}:J.object([J.Field{"kind",J.Text{"Ran"}},J.Field{"id",Method.number(id)}])
    case Sch.Skipped{id}:J.object([J.Field{"kind",J.Text{"Skipped"}},J.Field{"id",Method.number(id)}])
    case Sch.Applied{}:J.object([J.Field{"kind",J.Text{"Applied"}}])
def finished(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,+failed:Bool,observations:List<&2,Sch.Observation>,result:EntryApp.Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<T.MotionSchema>>)))) -> State:
  match result:
    case (app,(ns,(name,(steps,requirements)))):State{Single.Attached{EntryApp.update(~Bool,~phase_record,app,failed)},namespace,boundaries,List.append(&2,J.Value,schedules,[J.object([J.Field{"kind",J.Text{"Schedule"}},J.Field{"namespace",Method.number(ns)},J.Field{"name",J.Text{name}},J.Field{"steps",J.array(Method.values(~Sch.Step,~schedule_step,steps))},J.Field{"requirements",J.array(Method.values(~SP.Requirement<T.MotionSchema>,~requirement,requirements))},J.Field{"failed",J.Boolean{failed}},J.Field{"observations",J.array(Method.values(~Sch.Observation,~observation,observations))}])]),status(phase,failed)}
def executed(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,result:Single.RunResult<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Single.Finished{app,observations}:finished(phase,namespace,boundaries,schedules,False{},observations,EntryApp.describe(app))
    case Single.Failed{app,_,observations}:finished(phase,namespace,boundaries,schedules,True{},observations,EntryApp.describe(app))
    case Single.Rejected{app}:State{Single.Attached{app},namespace,boundaries,List.append(&2,J.Value,schedules,[J.object([J.Field{"kind",J.Text{"ScheduleRejected"}}])]),Stopped{"schedule rejected"}}
    case Single.Missing{app,missing}:State{Single.Attached{app},namespace,boundaries,List.append(&2,J.Value,schedules,[J.object([J.Field{"kind",J.Text{"Missing"}},J.Field{"requirements",J.array(Method.values(~SP.Requirement<T.MotionSchema>,~requirement,missing))}])]),Stopped{"missing provision"}}
def run_returned(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,result:Execute.Run<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Execute.Run{result,_}:executed(phase,namespace,boundaries,schedules,result)
def replanned(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:run_returned(phase,namespace,boundaries,schedules,EntryApp.run(app))
    case slot:State{slot,namespace,boundaries,schedules,Stopped{"invalid schedule plan"}}
def run_slot(+phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:replanned(phase,namespace,boundaries,schedules,EntryApp.replan(app,"FailedTxn/phase" ++ U32.show(phase)))
    case slot:State{slot,namespace,boundaries,schedules,Stopped{"invalid schedule plan"}}
def run_phase(phase:U32,state:State) -> State:
  match state:
    case State{app,namespace,boundaries,schedules,Complete{}}:run_slot(phase,namespace,boundaries,schedules,app)
    case state:state
def boundary_name(value:Boundary.Boundary) -> String:
  match value:
    case Boundary.Boundary{_,phase,_}:phase
def boundary_captured(boundary:Boundary.Boundary,observed:F.World() & S.Runtime()) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match observed:
    case (world,owners):(world,(owners,boundary))
def boundary_returned(owners:S.Runtime(),observed:F.World() & Boundary.Boundary) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match observed:
    case (world,+boundary):boundary_captured(boundary,CaptureState.boundary_runtime(boundary_name(boundary),world,owners))
def boundary_snapshot(world:F.World(),owners:S.Runtime(),name:String) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match owners:
    case (owned,S.Shared{meta,tick,+frame}):boundary_returned((owned,S.Shared{meta,tick,frame}),Boundary.run(name,frame,world))
def boundary_observed(namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,status:Status,result:EntryApp.Slot() & Boundary.Boundary) -> State:
  match result:
    case (app,boundary):State{app,namespace,List.append(&2,Boundary.Boundary,boundaries,[boundary]),schedules,status}
def boundary(name:String,state:State) -> State:
  match state:
    case State{app,namespace,boundaries,schedules,status}:boundary_observed(namespace,boundaries,schedules,status,EntryApp.project(~String,~Boundary.Boundary,~boundary_snapshot,app,name))
def step(+iteration:U32,state:State) -> State:
  boundary("disposed",run_phase(6,phase(iteration,6,boundary("applied-FIFO",run_phase(5,phase(iteration,5,run_phase(4,phase(iteration,4,boundary("retry-before-barrier",run_phase(3,phase(iteration,3,run_phase(2,phase(iteration,2,boundary("failed-before-barrier",run_phase(1,phase(iteration,1,state))))))))))))))))
def loops(fuel:Nat,+iteration:U32,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,U32.add(iteration,1),step(iteration,state))
def method_status(value:Status) -> J.Value:
  match value:
    case Complete{}:J.object([J.Field{"kind",J.Text{"Complete"}}])
    case Stopped{reason}:J.object([J.Field{"kind",J.Text{"Stopped"}},J.Field{"reason",J.Text{reason}}])
def final_observer(world:F.World(),owners:S.Runtime(),status:J.Value) -> F.World() & (S.Runtime() & Method.State):CaptureState.final_runtime(world,owners,status)
def final_returned(namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,J.Value>,status:Status,value:EntryApp.Slot() & Method.State) -> State & Method.State:
  match value:
    case (app,method):(State{app,namespace,boundaries,schedules,status},method)
def method_final(value:State) -> State & Method.State:
  match value:
    case State{app,namespace,boundaries,schedules,+status}:final_returned(namespace,boundaries,schedules,status,EntryApp.project(~J.Value,~Method.State,~final_observer,app,method_status(status)))
def public_boundaries(values:List<&2,Boundary.Boundary>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case Boundary.Boundary{_,_,record} <> rest:record <> public_boundaries(rest)
def public_owned(world:F.World(),value:S.Runtime() & List<&2,J.Value>) -> F.World() & (S.Runtime() & List<&2,J.Value>):
  match value:
    case (owners,calls):(world,(owners,calls))
def public_observed(world:F.World(),owners:S.Runtime(),_:Unit) -> F.World() & (S.Runtime() & List<&2,J.Value>):public_owned(world,S.public_calls(owners))
def public_returned(namespace:U32,+boundaries:List<&2,Boundary.Boundary>,+schedules:List<&2,J.Value>,status:Status,observed:EntryApp.Slot() & List<&2,J.Value>) -> State & J.Value:
  match observed:
    case (app,calls):(State{app,namespace,boundaries,schedules,status},J.object([J.Field{"boundaries",J.array(public_boundaries(boundaries))},J.Field{"schedules",J.array(schedules)},J.Field{"calls",J.array(calls)}]))
def public_state(value:State) -> State & J.Value:
  match value:
    case State{app,namespace,boundaries,schedules,status}:public_returned(namespace,boundaries,schedules,status,EntryApp.project(~Unit,~List<&2,J.Value>,~public_observed,app,Unit{}))
