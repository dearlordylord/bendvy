import Base
import motion-domain.bend as D
import motion-systems.bend as S
import motion-schedule.bend as Schedule
import motion-app.bend as EntryApp
import ../dense-runtime-v1/motion.bend as F
import ../dense-runtime-v1/types.bend as Types
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields

type Ids is Data:
  Ids{select:U32,reserve:U32,dispose:U32,observe:U32}
type Status is Data:
  Complete{}
  BodyFailed{}
  Refused{}
  Invalid{}
type Log is Data:
  Log{name:String,steps:List<&2,Sch.Step>,status:Status,observations:Maybe<&2,List<&2,Sch.Observation>>}
type State is Type:
  State{app:EntryApp.Slot(),foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,status:Status}
def catalog_ids(ids:Ids) -> List<&2,U32>:
  match ids:
    case Ids{s,r,d,o}:[s,r,d,o]
def catalog_list(owners:S.Runtime(),ids:List<&2,U32>) -> S.Runtime() & Ids:
  match ids:
    case s <> (r <> (d <> (o <> []))):(owners,Ids{s,r,d,o})
    case _:(owners,Ids{0,0,0,0})
def catalog_done(result:S.Runtime() & List<&2,Fields.Fields<Types.MotionSchema>>) -> S.Runtime() & Ids:
  match result:
    case (owners,fields):catalog_list(owners,Schedule.ids(fields))
def catalog(owners:S.Owners) -> S.Runtime() & Ids:catalog_done(Schedule.fold(S.pack(owners)))
def phase_frame(value:U32,frame:D.Frame) -> D.Frame:
  match frame:
    case D.Frame{count,i,_,target,pending,foreign,stale,reservations}:D.Frame{count,i,value,target,pending,foreign,stale,reservations}
def update_phase(owners:S.Runtime(),args:U32 & U32) -> S.Runtime():
  match owners args:
    case (local,S.Shared{frame,digest,boundaries,calls,_}),(stage,value):(local,S.Shared{phase_frame(value,frame),digest,boundaries,calls,stage})
def next_frame(frame:D.Frame) -> D.Frame:
  match frame:
    case D.Frame{count,i,p,target,pending,foreign,stale,reservations}:D.Frame{count,U32.add(i,1),p,target,pending,foreign,stale,reservations}
def update_next(owners:S.Runtime(),_:Unit) -> S.Runtime():
  match owners:
    case (local,S.Shared{frame,digest,boundaries,calls,stage}):(local,S.Shared{next_frame(frame),digest,boundaries,calls,stage})
def next_slot(slot:EntryApp.Slot()) -> EntryApp.Slot():
  match slot:
    case Single.Attached{app}:Single.Attached{EntryApp.update(~Unit,~update_next,app,Unit{})}
    case slot:slot
def next(state:State) -> State:
  match state:
    case State{app,foreign,ids,namespace,logs,Complete{}}:State{next_slot(app),foreign,ids,namespace,logs,Complete{}}
    case state:state
def finished(foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,+status:Status,observations:Maybe<&2,List<&2,Sch.Observation>>,description:EntryApp.Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<Types.MotionSchema>>)))) -> State:
  match description:
    case (app,(_,(+name,(+steps,_)))):State{Single.Attached{app},foreign,ids,namespace,List.append(&2,Log,logs,[Log{name,steps,status,observations}]),status}
def executed(foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,result:Single.RunResult<EntryApp.Application(),Types.MotionSchema,Unit>) -> State:
  match result:
    case Single.Finished{app,observations}:finished(foreign,ids,namespace,logs,Complete{},Some{observations},EntryApp.describe(app))
    case Single.Failed{app,_,observations}:finished(foreign,ids,namespace,logs,BodyFailed{},Some{observations},EntryApp.describe(app))
    case Single.Rejected{app}:finished(foreign,ids,namespace,logs,Refused{},None{},EntryApp.describe(app))
    case Single.Missing{app,_}:State{Single.Attached{app},foreign,ids,namespace,logs,Invalid{}}
def run_returned(foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,result:Execute.Run<EntryApp.Application(),Types.MotionSchema,Unit>) -> State:
  match result:
    case Execute.Run{result,_}:executed(foreign,ids,namespace,logs,result)
def replanned(foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:run_returned(foreign,ids,namespace,logs,EntryApp.run(app))
    case slot:State{slot,foreign,ids,namespace,logs,Invalid{}}
def run_slot(name:String,stage:U32,value:U32,foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,slot:EntryApp.Slot()) -> State:
  match slot:
    case Single.Attached{app}:replanned(foreign,ids,namespace,logs,EntryApp.replan(EntryApp.update(~(U32 & U32),~update_phase,app,(stage,value)),name))
    case slot:State{slot,foreign,ids,namespace,logs,Invalid{}}
def run_phase(name:String,stage:U32,value:U32,state:State) -> State:
  match state:
    case State{app,foreign,ids,namespace,logs,Complete{}}:run_slot(name,stage,value,foreign,ids,namespace,logs,app)
    case state:state
def step(state:State) -> State:
  next(run_phase("Lifecycle/ObserveAfter",5,2,run_phase("Lifecycle/DisposeBarrier",4,1,run_phase("Lifecycle/ObserveApplied",3,1,run_phase("Lifecycle/Apply",2,0,run_phase("Lifecycle/ObservePending",1,0,run_phase("Lifecycle/SelectReserve",0,0,state)))))))
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
def initial_catalog(world:D.World(),foreign:D.World(),namespace:U32,observed:S.Runtime() & Ids) -> State:
  match observed:
    case (owners,ids):State{EntryApp.create(world,owners),foreign,ids,namespace,[],Complete{}}
def initial_named(foreign:D.World(),owners:S.Owners,observed:D.World() & U32) -> State:
  match observed:
    case (world,namespace):initial_catalog(world,foreign,namespace,catalog(owners))
def initial(world:D.World(),foreign:D.World(),owners:S.Owners) -> State:initial_named(foreign,owners,W.namespace(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,world))
