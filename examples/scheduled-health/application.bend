import Base
import schema.bend as S
import components.bend as D
import system.bend as Decay
import ../../src/ecs/ordinary-system.bend as O
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/ordinary-query-declaration.bend as Decl

type Error is Data:
  SystemError{error:Q.Error<Decay.Error>}
  RegistrationRejected{}
def Owners() -> Type:Decay.Owner() & List<&2,D.Health>
def Schedule() -> Type:Sch.Schedule<S.Schema,S.Store,Unit,Unit,Owners()>
def values(rows:List<&2,D.Health>) -> String:
  match rows:
    case []:""
    case D.Health{value} <> []:F32.show(value)
    case D.Health{value} <> rest:F32.show(value) ++ "," ++ values(rest)
def returned(value:Sys.RunResult<S.Schema,S.Store,Unit,Unit,Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,Decay.Runner()> & (String & List<&2,Decl.Clause<S.Schema>>)) -> Owners() & Sys.Outcome<S.World(),Error,Unit>:
  match value:
    case (Sys.Completed{registry,Sys.Succeeded{world,rows}},(slot,clauses)):((O.Owner{registry,slot,clauses},rows),Sys.Succeeded{world,Unit{}})
    case (Sys.Completed{registry,Sys.Failed{world,error}},(slot,clauses)):((O.Owner{registry,slot,clauses},[]),Sys.Failed{world,SystemError{error}})
    case (Sys.RegistrationRejected{registry,world,_},(slot,clauses)):((O.Owner{registry,slot,clauses},[]),Sys.Failed{world,RegistrationRejected{}})
def dispatch(owners:Owners(),world:S.World(),_:U32) -> Owners() & Sys.Outcome<S.World(),Error,Unit>:
  match owners:
    case (owner,_):returned(Decay.tick(owner,world))
def condition(world:S.World(),_:U32) -> S.World() & Bool:(world,True{})
def sentinel(value:S.World() & C.Access<D.Health>) -> String:
  match value:
    case (_,C.Found{D.Health{value}}):"untouched=" ++ F32.show(value)
    case _:"ERROR: sentinel missing"
def finished(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  sentinel(C.get(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,S.health_family(),world,handle))
def after_tick(next:Schedule() -> S.World() -> String,tick:U32,result:Sch.RunResult<S.Schema,S.Store,Unit,Unit,Owners(),Error>) -> String:
  match result:
    case Sch.Finished{Sch.Schedule{+ns,+name,+steps,(owner,+rows)},world,_}:"tick=" ++ U32.show(tick) ++ " health=" ++ values(rows) ++ "\n" ++ next(Sch.Schedule{ns,name,steps,(owner,rows)},world)
    case _:"ERROR: schedule run"
def ticks(left:Nat,+tick:U32,handle:W.Handle<S.Schema>,schedule:Schedule(),world:S.World()) -> String:
  match left:
    case 0n:finished(world,handle)
    case 1n++rest:after_tick(s => w => ticks(rest,(tick + 1:U32),handle,s,w),tick,Sch.run(~S.Schema,~S.Store,~Unit,~Unit,~Owners(),~Error,~dispatch,~condition,schedule,world))
def built(world:S.World(),handle:W.Handle<S.Schema>,result:Sch.Build<S.Schema,S.Store,Unit,Unit,Owners()>) -> String:
  match result:
    case Sch.Built{schedule}:ticks(6n,1,handle,schedule,world)
    case _:"ERROR: schedule build"
def scheduled(world:S.World(),handle:W.Handle<S.Schema>,owner:Decay.Owner()) -> String:
  match owner:
    case O.Owner{Sys.Registry{+ns,+id,name,access,cursor},slot,clauses}:built(world,handle,Sch.build(~S.Schema,~S.Store,~Unit,~Unit,~Owners(),ns,"Health simulation",[Sch.Barrier{},Sch.System{id,0}],[id],(O.Owner{Sys.Registry{ns,id,name,access,cursor},slot,clauses},[])))
def pending(handle:W.Handle<S.Schema>,result:Owners() & Sys.Outcome<S.World(),Error,Unit>) -> String:
  match result:
    case ((owner,rows),Sys.Succeeded{world,_}):"before-barrier=" ++ values(rows) ++ "\n" ++ scheduled(world,handle,owner)
    case _:"ERROR: pending system"
def registered(handle:W.Handle<S.Schema>,result:O.Defined<S.Schema,S.World(),Sys.Registry<S.Schema,S.Store,Unit,Unit,Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,Decay.Runner()>>) -> String:
  match result:
    case O.Defined{world,owner}:pending(handle,dispatch((owner,[]),world,0))
    case _:"ERROR: registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:registered(handle,Decay.define(world))
