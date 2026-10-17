import Base
import health-domain.bend as D
import health-systems.bend as S
import ../dense-runtime-v1/health.bend as F
import ../dense-runtime-v1/types.bend as Types
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/schedule.bend as Sch

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
  State{world:D.World(),foreign:D.World(),owners:S.Owners,ids:Ids,namespace:U32,logs:List<&2,Log>,status:Status}
def catalog(owners:S.Owners) -> S.Owners & Ids:
  match owners:
    case S.Owners{Local.Instance{s0,+i0,n0,a0,l0},Local.Instance{s1,+i1,n1,a1,l1},Local.Instance{s2,+i2,n2,a2,l2},Local.Instance{s3,+i3,n3,a3,l3},frame,digest,boundaries,calls}:(S.Owners{Local.Instance{s0,i0,n0,a0,l0},Local.Instance{s1,i1,n1,a1,l1},Local.Instance{s2,i2,n2,a2,l2},Local.Instance{s3,i3,n3,a3,l3},frame,digest,boundaries,calls},Ids{i0,i1,i2,i3})
def catalog_ids(ids:Ids) -> List<&2,U32>:
  match ids:
    case Ids{s,r,d,o}:[s,r,d,o]
def scheduled(foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,result:Sch.RunResult<Types.HealthSchema,F.Store(),F.Resources(),Nat,S.Owners,Unit>) -> State:
  match result:
    case Sch.Finished{Sch.Schedule{_,+name,+steps,owners},world,observations}:State{world,foreign,owners,ids,namespace,List.append(&2,Log,logs,[Log{name,steps,Complete{},Some{observations}}]),Complete{}}
    case Sch.Failed{Sch.Schedule{_,+name,+steps,owners},world,_,observations}:State{world,foreign,owners,ids,namespace,List.append(&2,Log,logs,[Log{name,steps,BodyFailed{},Some{observations}}]),BodyFailed{}}
    case Sch.Rejected{Sch.Schedule{_,+name,+steps,owners},world}:State{world,foreign,owners,ids,namespace,List.append(&2,Log,logs,[Log{name,steps,Refused{},None{}}]),Refused{}}
def built(world:D.World(),foreign:D.World(),ids:Ids,namespace:U32,logs:List<&2,Log>,result:Sch.Build<Types.HealthSchema,F.Store(),F.Resources(),Nat,S.Owners>) -> State:
  match result:
    case Sch.Built{schedule}:scheduled(foreign,ids,namespace,logs,Sch.run(~Types.HealthSchema,~F.Store(),~F.Resources(),~Nat,~S.Owners,~Unit,~S.dispatch,~S.condition,schedule,world))
    case Sch.Invalid{owners}:State{world,foreign,owners,ids,namespace,logs,Invalid{}}
def run_steps(name:String,steps:List<&2,Sch.Step>,state:State) -> State:
  match state:
    case State{world,foreign,owners,+ids,+namespace,logs,Complete{}}:built(world,foreign,ids,namespace,logs,Sch.build(~Types.HealthSchema,~F.Store(),~F.Resources(),~Nat,~S.Owners,namespace,name,steps,catalog_ids(ids),owners))
    case state:state

def phase_owners(phase:U32,owners:S.Owners) -> S.Owners:
  match owners:
    case S.Owners{s,r,d,o,D.Frame{count,i,_,target,pending,foreign,stale,reservations},digest,boundaries,calls}:S.Owners{s,r,d,o,D.Frame{count,i,phase,target,pending,foreign,stale,reservations},digest,boundaries,calls}
def phase(value:U32,state:State) -> State:
  match state:
    case State{world,foreign,owners,ids,namespace,logs,Complete{}}:State{world,foreign,phase_owners(value,owners),ids,namespace,logs,Complete{}}
    case state:state
def next_owners(owners:S.Owners) -> S.Owners:
  match owners:
    case S.Owners{s,r,d,o,D.Frame{count,i,p,target,pending,foreign,stale,reservations},digest,boundaries,calls}:S.Owners{s,r,d,o,D.Frame{count,U32.add(i,1),p,target,pending,foreign,stale,reservations},digest,boundaries,calls}
def next(state:State) -> State:
  match state:
    case State{world,foreign,owners,ids,namespace,logs,Complete{}}:State{world,foreign,next_owners(owners),ids,namespace,logs,Complete{}}
    case state:state
def after_observe(after:State -> State,id:U32,label:String,state:State) -> State:after(run_steps(label,[Sch.System{id,0}],state))
def after_dispose(observe:U32,state:State) -> State:after_observe(next,observe,"Lifecycle/ObserveAfter",phase(2,state))
def dispose(dispose:U32,observe:U32,state:State) -> State:after_dispose(observe,run_steps("Lifecycle/DisposeBarrier",[Sch.System{dispose,0},Sch.Barrier{}],state))
def after_applied(disposeId:U32,+observe:U32,state:State) -> State:dispose(disposeId,observe,run_steps("Lifecycle/ObserveApplied",[Sch.System{observe,0}],phase(1,state)))
def after_pending(dispose:U32,observe:U32,state:State) -> State:after_applied(dispose,observe,run_steps("Lifecycle/Apply",[Sch.Barrier{}],state))
def after_reserved(dispose:U32,+observe:U32,state:State) -> State:after_pending(dispose,observe,run_steps("Lifecycle/ObservePending",[Sch.System{observe,0}],state))
def step_ids(ids:Ids,state:State) -> State:
  match ids:
    case Ids{select,reserve,dispose,observe}:after_reserved(dispose,observe,run_steps("Lifecycle/SelectReserve",[Sch.System{select,0},Sch.System{reserve,0}],phase(0,state)))
def step(state:State) -> State:
  match state:
    case State{world,foreign,owners,+ids,namespace,logs,status}:step_ids(ids,State{world,foreign,owners,ids,namespace,logs,status})
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
def initial_catalog(world:D.World(),foreign:D.World(),namespace:U32,observed:S.Owners & Ids) -> State:
  match observed:
    case (owners,ids):State{world,foreign,owners,ids,namespace,[],Complete{}}
def initial_named(foreign:D.World(),owners:S.Owners,observed:D.World() & U32) -> State:
  match observed:
    case (world,namespace):initial_catalog(world,foreign,namespace,catalog(owners))
def initial(world:D.World(),foreign:D.World(),owners:S.Owners) -> State:initial_named(foreign,owners,W.namespace(~Types.HealthSchema,~F.Store(),~F.Resources(),~Nat,world))
