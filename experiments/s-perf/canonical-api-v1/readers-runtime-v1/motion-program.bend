import Base
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-family.bend as Family
import motion-systems.bend as S
import motion-reader.bend as Reader
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/event-family-routing.bend as Route

type Status is Data:
  Complete{}
  BodyFailed{}
  Refused{}
  Invalid{}
type Log is Data:
  Log{name:String,steps:List<&2,Sch.Step>,status:Status,observations:Maybe<&2,List<&2,Sch.Observation>>}
type State is Type:
  State{world:F.World(),owners:S.Owners,+namespace:U32,logs:List<&2,Log>,status:Status}
def condition(world:F.World(),slot:U32) -> F.World() & Bool:(world,U32.is_eq(slot,0))
def ids(owners:S.Owners) -> S.Owners & S.IDs:
  match owners:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,+ids,locals,reads}:(S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,ids,locals,reads},ids)
def catalog(value:S.IDs) -> List<&2,U32>:
  match value:
    case S.IDs{spawn,update,dispose,fast,slow}:[spawn,update,dispose,fast,slow]
def scheduled(namespace:U32,logs:List<&2,Log>,result:Sch.RunResult<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners,Unit>) -> State:
  match result:
    case Sch.Finished{Sch.Schedule{_,+name,+steps,owners},world,observations}:State{world,owners,namespace,Log{name,steps,Complete{},Some{observations}} <> logs,Complete{}}
    case Sch.Failed{Sch.Schedule{_,+name,+steps,owners},world,_,observations}:State{world,owners,namespace,Log{name,steps,BodyFailed{},Some{observations}} <> logs,BodyFailed{}}
    case Sch.Rejected{Sch.Schedule{_,+name,+steps,owners},world}:State{world,owners,namespace,Log{name,steps,Refused{},None{}} <> logs,Refused{}}
def built(world:F.World(),+namespace:U32,logs:List<&2,Log>,result:Sch.Build<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Owners>) -> State:
  match result:
    case Sch.Built{schedule}:scheduled(namespace,logs,Sch.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Owners,~Unit,~S.run,~condition,schedule,world))
    case Sch.Invalid{owners}:State{world,owners,namespace,logs,Invalid{}}
def run_catalog(name:String,steps:List<&2,Sch.Step>,world:F.World(),+namespace:U32,logs:List<&2,Log>,observed:S.Owners & S.IDs) -> State:
  match observed:
    case (owners,id):built(world,namespace,logs,Sch.build(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Owners,namespace,name,steps,catalog(id),owners))
def run_steps(name:String,steps:List<&2,Sch.Step>,state:State) -> State:
  match state:
    case State{world,owners,namespace,logs,Complete{}}:run_catalog(name,steps,world,namespace,logs,ids(owners))
    case state:state
def framed_owners(spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),fast:Reader.Provider(),slow:Reader.Provider(),frame:D.Frame,phase:U32,id:S.IDs,locals:List<&2,S.LocalCall>,reads:List<&2,S.ReadCall>,+namespace:U32,logs:List<&2,Log>,context:Family.Context()) -> State:
  match context:
    case Route.Runtime{world,meta,tick}:State{world,S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,id,locals,reads},namespace,logs,Complete{}}
def frame(state:State) -> State:
  match state:
    case State{world,S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,id,locals,reads},namespace,logs,Complete{}}:framed_owners(spawn,update,dispose,fast,slow,frame,phase,id,locals,reads,namespace,logs,Family.frame(Mixed.before_attempt(~T.MotionSchema,~F.Store(),~F.Resources(),~E.Publication,~Family.Family,~Unit,~Family.sync,~Reader.classify,Route.Runtime{world,meta,tick})))
    case state:state
def phase_owners(phase:U32,owners:S.Owners) -> S.Owners:
  match owners:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,_,id,locals,reads}:S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,id,locals,reads}
def phase(value:U32,state:State) -> State:
  match state:
    case State{world,owners,ns,logs,status}:State{world,phase_owners(value,owners),ns,logs,status}
def next_owners(owners:S.Owners) -> S.Owners:
  match owners:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,D.Frame{count,i,transient,reservations,facts},phase,id,locals,reads}:S.Owners{spawn,update,dispose,fast,slow,meta,tick,D.Frame{count,U32.add(i,1),transient,reservations,facts},phase,id,locals,reads}
def next(state:State) -> State:
  match state:
    case State{world,owners,ns,logs,status}:State{world,next_owners(owners),ns,logs,status}
def reader_steps(slow:Bool,update:U32,fast:U32,reader:U32) -> List<&2,Sch.Step>:
  match slow:
    case False{}:[Sch.System{update,0},Sch.System{fast,0}]
    case True{}:[Sch.System{update,0},Sch.System{fast,0},Sch.System{reader,0}]
def after_read(dispose:U32,state:State) -> State:next(frame(run_steps("DisposeBarrier",[Sch.System{dispose,0},Sch.Barrier{}],state)))
def after_spawn(update:U32,fast:U32,slow:U32,dispose:U32,iteration:U32,state:State) -> State:
  after_read(dispose,frame(run_steps("UpdateReaders",reader_steps(U32.is_eq(U32.mod(iteration,4),3),update,fast,slow),state)))
def step_frame(spawn:U32,update:U32,dispose:U32,fast:U32,slow:U32,world:F.World(),+namespace:U32,logs:List<&2,Log>,status:Status,observed:S.Owners & U32) -> State:
  match observed:
    case (owners,i):after_spawn(update,fast,slow,dispose,i,frame(run_steps("SpawnBarrier",[Sch.System{spawn,0},Sch.Barrier{}],State{world,owners,namespace,logs,status})))
def owners_iteration(owners:S.Owners) -> S.Owners & U32:
  match owners:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,D.Frame{count,+i,transient,reservations,facts},phase,id,locals,reads}:(S.Owners{spawn,update,dispose,fast,slow,meta,tick,D.Frame{count,i,transient,reservations,facts},phase,id,locals,reads},i)
def step_iteration(spawn:U32,update:U32,dispose:U32,fast:U32,slow:U32,state:State) -> State:
  match state:
    case State{world,owners,namespace,logs,status}:step_frame(spawn,update,dispose,fast,slow,world,namespace,logs,status,owners_iteration(owners))
def step_catalog(world:F.World(),+namespace:U32,logs:List<&2,Log>,status:Status,observed:S.Owners & S.IDs) -> State:
  match observed:
    case (owners,S.IDs{spawn,update,dispose,fast,slow}):step_iteration(spawn,update,dispose,fast,slow,State{world,owners,namespace,logs,status})
def step(state:State) -> State:
  match state:
    case State{world,owners,namespace,logs,status}:step_catalog(world,namespace,logs,status,ids(owners))
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
def read_pair_ids(label:String,state:State,ids:S.IDs) -> State:
  match ids:
    case S.IDs{_,_,_,fast,slow}:frame(run_steps(label,[Sch.System{fast,0},Sch.System{slow,0}],state))
def read_pair_catalog(label:String,world:F.World(),+namespace:U32,logs:List<&2,Log>,status:Status,observed:S.Owners & S.IDs) -> State:
  match observed:
    case (owners,ids):read_pair_ids(label,State{world,owners,namespace,logs,status},ids)
def read_pair(label:String,state:State) -> State:
  match state:
    case State{world,owners,namespace,logs,status}:read_pair_catalog(label,world,namespace,logs,status,ids(owners))
def prime(state:State) -> State:read_pair("Prime",phase(0,state))
def drain(state:State) -> State:read_pair("Drain",phase(2,state))
