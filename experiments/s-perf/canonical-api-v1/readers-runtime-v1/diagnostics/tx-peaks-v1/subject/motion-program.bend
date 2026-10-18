import Base
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-family.bend as Family
import motion-systems.bend as S
import motion-reader.bend as Reader
import ../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/event-family-routing.bend as Route

import motion-app.bend as EntryApp
import ../../../../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../src/ecs/schedule-provision.bend as SP
type Status is Data:
  Complete{}
  BodyFailed{}
  Refused{}
  Invalid{}
type Log is Data:
  Log{name:String,steps:List<&2,Sch.Step>,status:Status,observations:Maybe<&2,List<&2,Sch.Observation>>}
type State is Type:
  State{app:EntryApp.Slot(),namespace:U32,logs:List<&2,Log>,status:Status}
type View is Type:
  View{world:F.World(),owners:S.Owners,namespace:U32,logs:List<&2,Log>,status:Status}
type InspectionArgs is Data:
  InspectionArgs{namespace:U32,logs:List<&2,Log>,status:Status}
def start(world:F.World(),owners:S.Owners,namespace:U32) -> State:State{EntryApp.create(world,S.pack(0,owners)),namespace,[],Complete{}}
def inspection_returned(~Value:Data,stage:U32,result:View & Value) -> F.World() & (S.Runtime() & Value):
  match result:
    case (View{world,owners,_,_,_},value):(world,(S.pack(stage,owners),value))
def inspection_unpacked(~Value:Data,~observe:View -> View & Value,world:F.World(),args:InspectionArgs,result:S.Owners & U32) -> F.World() & (S.Runtime() & Value):
  match args result:
    case InspectionArgs{namespace,logs,status},(owners,stage):inspection_returned(~Value,stage,observe(View{world,owners,namespace,logs,status}))
def inspection(~Value:Data,~observe:View -> View & Value,world:F.World(),owners:S.Runtime(),args:InspectionArgs) -> F.World() & (S.Runtime() & Value):inspection_unpacked(~Value,~observe,world,args,S.unpack(owners))
def state_observed(~Value:Data,namespace:U32,logs:List<&2,Log>,status:Status,result:EntryApp.Slot() & Value) -> State & Value:
  match result:
    case (app,value):(State{app,namespace,logs,status},value)
def inspect(~Value:Data,~observe:View -> View & Value,state:State) -> State & Value:
  match state:
    case State{app,+namespace,+logs,+status}:state_observed(~Value,namespace,logs,status,EntryApp.project(~InspectionArgs,~Value,~inspection(~Value,~observe),app,InspectionArgs{namespace,logs,status}))
def finish_world(state:State) -> F.World():
  match state:
    case State{Single.Attached{Entry.Application{Single.Application{SchemaApp.Application{_,Build.Registered{world,_,_,_}},_,_,_,_,_},_}},_,_,_}:world
    case State{Single.Invalid{Exec.Registered{Build.Registered{world,_,_,_},_}},_,_,_}:world

def stage_owners(value:S.Runtime(),stage:U32) -> S.Runtime():
  match value:
    case (owners,S.Shared{meta,tick,frame,phase,locals,reads,_}):(owners,S.Shared{meta,tick,frame,phase,locals,reads,stage})
def phase_owners(value:S.Runtime(),phase:U32) -> S.Runtime():
  match value:
    case (owners,S.Shared{meta,tick,frame,_,locals,reads,stage}):(owners,S.Shared{meta,tick,frame,phase,locals,reads,stage})
def next_owners(value:S.Runtime(),_:Unit) -> S.Runtime():
  match value:
    case (owners,S.Shared{meta,tick,D.Frame{count,i,transient,reservations,facts},phase,locals,reads,stage}):(owners,S.Shared{meta,tick,D.Frame{count,U32.add(i,1),transient,reservations,facts},phase,locals,reads,stage})
def update_slot(~Args:Type,~modify:S.Runtime() -> Args -> S.Runtime(),slot:EntryApp.Slot(),args:Args) -> EntryApp.Slot():
  match slot:
    case Single.Attached{app}:Single.Attached{EntryApp.update(~Args,~modify,app,args)}
    case slot:slot
def phase(value:U32,state:State) -> State:
  match state:
    case State{app,namespace,logs,status}:State{update_slot(~U32,~phase_owners,app,value),namespace,logs,status}
def next(state:State) -> State:
  match state:
    case State{app,namespace,logs,status}:State{update_slot(~Unit,~next_owners,app,Unit{}),namespace,logs,status}
def framed(owners:S.Owned(),frame:D.Frame,phase:U32,locals:List<&2,S.LocalCall>,reads:List<&2,S.ReadCall>,stage:U32,context:Family.Context()) -> F.World() & (S.Runtime() & Unit):
  match context:
    case Route.Runtime{world,meta,tick}:(world,((owners,S.Shared{meta,tick,frame,phase,locals,reads,stage}),Unit{}))
def framing(world:F.World(),value:S.Runtime(),_:Unit) -> F.World() & (S.Runtime() & Unit):
  match value:
    case (owners,S.Shared{meta,tick,frame,phase,locals,reads,stage}):framed(owners,frame,phase,locals,reads,stage,Family.frame(Mixed.before_attempt(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Family.sync,~Reader.classify,Route.Runtime{world,meta,tick})))
def frame_returned(namespace:U32,logs:List<&2,Log>,result:EntryApp.Slot() & Unit) -> State:
  match result:
    case (app,_):State{app,namespace,logs,Complete{}}
def frame(state:State) -> State:
  match state:
    case State{app,namespace,logs,Complete{}}:frame_returned(namespace,logs,EntryApp.project(~Unit,~Unit,~framing,app,Unit{}))
    case state:state

def logged(namespace:U32,logs:List<&2,Log>,+status:Status,observations:Maybe<&2,List<&2,Sch.Observation>>,result:EntryApp.Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<T.MotionSchema>>)))) -> State:
  match result:
    case (app,(_,(name,(steps,_)))):State{Single.Attached{app},namespace,Log{name,steps,status,observations} <> logs,status}
def executed(namespace:U32,logs:List<&2,Log>,result:Single.RunResult<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Single.Finished{app,observations}:logged(namespace,logs,Complete{},Some{observations},EntryApp.describe(app))
    case Single.Failed{app,_,observations}:logged(namespace,logs,BodyFailed{},Some{observations},EntryApp.describe(app))
    case Single.Rejected{app}:logged(namespace,logs,Refused{},None{},EntryApp.describe(app))
    case Single.Missing{app,_}:State{Single.Attached{app},namespace,logs,Invalid{}}
def run_returned(namespace:U32,logs:List<&2,Log>,result:Execute.Run<EntryApp.Application(),T.MotionSchema,Unit>) -> State:
  match result:
    case Execute.Run{result,_}:executed(namespace,logs,result)
def replanned(namespace:U32,logs:List<&2,Log>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:run_returned(namespace,logs,EntryApp.run(app))
    case slot:State{slot,namespace,logs,Invalid{}}
def run_updated(name:String,namespace:U32,logs:List<&2,Log>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:replanned(namespace,logs,EntryApp.replan(app,name))
    case slot:State{slot,namespace,logs,Invalid{}}
def run_stage(stage:U32,name:String,state:State) -> State:
  match state:
    case State{app,namespace,logs,Complete{}}:run_updated(name,namespace,logs,update_slot(~U32,~stage_owners,app,stage))
    case state:state
def step(state:State) -> State:next(frame(run_stage(3,"DisposeBarrier",frame(run_stage(2,"UpdateReaders",frame(run_stage(1,"SpawnBarrier",state)))))))
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
def prime(state:State) -> State:frame(run_stage(0,"Prime",phase(0,state)))
def drain(state:State) -> State:frame(run_stage(0,"Drain",phase(2,state)))
