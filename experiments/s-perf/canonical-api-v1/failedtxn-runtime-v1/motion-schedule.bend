import Base
import ../dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-local.bend as L
import motion-registration.bend as Reg
import motion-systems.bend as S
import motion-grants.bend as Grants
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/ordinary-service-declaration.bend as Service

type IDs is Data:
  IDs{a:U32,b:U32,publications:U32,dispose:U32}
def catalog(owners:S.Owners) -> S.Owners & IDs:
  match owners:
    case S.Owners{Reg.Owners{Local.Instance{an,+a,aa,ax,al},Local.Instance{bn,+b,ba,bx,bl},Ordinary.Provider{Sys.Registry{pn,+p,pa,px,pc},po,pp,pd},meta,tick},Sys.Registry{dn,+d,da,dx,dc},frame}:(S.Owners{Reg.Owners{Local.Instance{an,a,aa,ax,al},Local.Instance{bn,b,ba,bx,bl},Ordinary.Provider{Sys.Registry{pn,p,pa,px,pc},po,pp,pd},meta,tick},Sys.Registry{dn,d,da,dx,dc},frame},IDs{a,b,p,d})
def ids(value:IDs) -> List<&2,U32>:
  match value:
    case IDs{a,b,p,d}:[a,b,p,d]
def entry(id:U32) -> SP.Plan<T.MotionSchema>:SP.Entry{Sch.System{id,0},[Grants.required()]}
def plain(id:U32) -> SP.Plan<T.MotionSchema>:SP.Entry{Sch.System{id,0},[]}
def plan(phase:U32,value:IDs) -> SP.Plan<T.MotionSchema>:
  match phase value:
    case 0, IDs{_,b,p,_}:SP.Sequence{entry(b),plain(p)}
    case 1, IDs{a,b,_,_}:SP.Sequence{entry(a),entry(b)}
    case 2, IDs{_,_,p,_}:plain(p)
    case 3, IDs{_,b,_,_}:entry(b)
    case 4, IDs{_,_,p,_}:plain(p)
    case 5, _:SP.Entry{Sch.Barrier{},[]}
    case 6, IDs{_,_,_,d}:SP.Sequence{plain(d),SP.Entry{Sch.Barrier{},[]}}
    case _, _:SP.Empty{}
def provided(result:F.World() & List<&2,Service.Status<T.MotionSchema>>) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:
  match result:
    case (world,statuses):(world,Service.available(~T.MotionSchema,statuses))
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:provided(Grants.scan(world))
def step_text(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ ";" ++ U32.show(condition) ++ "}"
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.Barrier{}:"Barrier"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied"
