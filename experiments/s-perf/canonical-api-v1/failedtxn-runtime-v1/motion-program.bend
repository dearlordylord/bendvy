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

import motion-app.bend as EntryApp
import motion-doc-world.bend as DW
import report-doc.bend as Doc
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
type Status is Data:
  Complete{}
  Stopped{reason:String}
type State is Type:
  State{app:EntryApp.Slot(),namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status}
type Snapshot is Data:
  Snapshot{world:Doc.Doc,owners:Doc.Doc,ids:List<&2,U32>}
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
def snapshot_fold(observed:F.World() & Doc.Doc,ownersDoc:Doc.Doc,result:S.Runtime() & List<&2,Fields.Fields<T.MotionSchema>>) -> F.World() & (S.Runtime() & Snapshot):
  (world,worldDoc)=observed
  (owners,fields)=result
  (world,(owners,Snapshot{worldDoc,ownersDoc,Schedule.ids(fields)}))
def snapshot_owners(observed:F.World() & Doc.Doc,result:S.Owners & Doc.Doc) -> F.World() & (S.Runtime() & Snapshot):
  (owners,text)=result
  snapshot_fold(observed,text,Schedule.fold(S.pack(owners)))
def snapshot(world:F.World(),owners:S.Runtime(),_:Unit) -> F.World() & (S.Runtime() & Snapshot):snapshot_owners(DW.world(world),Observe.owners(S.unpack(owners)))
def state_observed(namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status,result:EntryApp.Slot() & Snapshot) -> State & Snapshot:
  (app,snapshot)=result
  (State{app,namespace,boundaries,schedules,status},snapshot)
def observe(state:State) -> State & Snapshot:
  match state:
    case State{app,namespace,boundaries,schedules,status}:state_observed(namespace,boundaries,schedules,status,EntryApp.project(~Unit,~Snapshot,~snapshot,app,Unit{}))
def finished(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,+failed:Bool,observations:List<&2,Sch.Observation>,result:EntryApp.Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<T.MotionSchema>>)))) -> State:
  match result:
    case (app,(ns,(name,(steps,requirements)))):State{Single.Attached{app},namespace,boundaries,List.append(&2,String,schedules,["namespace=" ++ U32.show(ns) ++ ";name=" ++ O.audit_effect(name) ++ ";steps=" ++ List.show(&2,Sch.Step,Schedule.step_text,steps) ++ ";requirements=" ++ List.show(&2,SP.Requirement<T.MotionSchema>,requirement,requirements) ++ ";failed=" ++ Bool.show(failed) ++ ";observations=" ++ List.show(&2,Sch.Observation,Schedule.observation,observations)]),status(phase,failed)}
def executed(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,result:Single.RunResult<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Single.Finished{app,observations}:finished(phase,namespace,boundaries,schedules,False{},observations,EntryApp.describe(app))
    case Single.Failed{app,_,observations}:finished(phase,namespace,boundaries,schedules,True{},observations,EntryApp.describe(app))
    case Single.Rejected{app}:State{Single.Attached{app},namespace,boundaries,List.append(&2,String,schedules,["ScheduleRejected"]),Stopped{"schedule rejected"}}
    case Single.Missing{app,missing}:State{Single.Attached{app},namespace,boundaries,List.append(&2,String,schedules,["Missing=" ++ List.show(&2,SP.Requirement<T.MotionSchema>,requirement,missing)]),Stopped{"missing provision"}}
def run_returned(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,result:Execute.Run<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Execute.Run{result,_}:executed(phase,namespace,boundaries,schedules,result)
def replanned(phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:run_returned(phase,namespace,boundaries,schedules,EntryApp.run(app))
    case slot:State{slot,namespace,boundaries,schedules,Stopped{"invalid schedule plan"}}
def run_slot(+phase:U32,namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:replanned(phase,namespace,boundaries,schedules,EntryApp.replan(app,"FailedTxn/phase" ++ U32.show(phase)))
    case slot:State{slot,namespace,boundaries,schedules,Stopped{"invalid schedule plan"}}
def run_phase(phase:U32,state:State) -> State:
  match state:
    case State{app,namespace,boundaries,schedules,Complete{}}:run_slot(phase,namespace,boundaries,schedules,app)
    case state:state
def boundary_returned(dispose:Dispose.Registry(),frame:S.Frame,registered:Reg.Owners,observed:F.World() & Boundary.Boundary) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match observed:
    case (world,boundary):(world,(S.pack(S.Owners{registered,dispose,frame}),boundary))
def boundary_owners(name:String,world:F.World(),dispose:Dispose.Registry(),+frame:S.Frame,observed:Reg.Owners & String) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match observed:
    case (registered,text):boundary_returned(dispose,frame,registered,Boundary.run(name,text,frame,world))
def boundary_snapshot(world:F.World(),owners:S.Runtime(),name:String) -> F.World() & (S.Runtime() & Boundary.Boundary):
  match owners:
    case (((a,b),(pub,dispose)),S.Shared{meta,tick,frame}):boundary_owners(name,world,dispose,frame,Observe.registered(Reg.Owners{a,b,pub,meta,tick}))
def boundary_observed(namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status,result:EntryApp.Slot() & Boundary.Boundary) -> State:
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
