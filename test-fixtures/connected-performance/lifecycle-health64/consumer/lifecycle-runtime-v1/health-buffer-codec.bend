import Base
import ../../../lifecycle-motion64/consumer/lifecycle-runtime-v1/motion-varint.bend as Var
import health-registration.bend as Reg
import health-domain.bend as D
import health-systems.bend as S
import health-program.bend as Program
import ../dense-runtime-v1/health.bend as F
import ../dense-runtime-v1/health-logical.bend as Logical
import ../../../../../src/ecs/component.bend as Cmp
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../src/ecs/schedule.bend as Sch
import health-codec-values.bend as V
import ../../../lifecycle-motion64/consumer/lifecycle-runtime-v1/motion-encode-buffer.bend as B
import ../../../lifecycle-motion64/consumer/dense-runtime-v1/types.bend as T
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/entity-key.bend as Key
import ../../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../../src/ecs/lifecycle.bend as Lifecycle
import ../../../../../src/ecs/transaction.bend as Tx

def text(value:String,buffer:B.Buffer) -> B.Buffer:B.text(value,buffer)
def u(value:U32,buffer:B.Buffer) -> B.Buffer:B.u(value,buffer)
def n(value:Nat,buffer:B.Buffer) -> B.Buffer:text(Var.nat(value),buffer)
def bool(value:Bool,buffer:B.Buffer) -> B.Buffer:
  match value:
    case False{}:text("0",buffer)
    case True{}:text("1",buffer)
def chars(value:String,buffer:B.Buffer) -> B.Buffer:
  match value:
    case SNil{}:buffer
    case SCon{head,rest}:chars(rest,u(Char.to_u32(head),buffer))
def string_copy(+value:String,buffer:B.Buffer) -> B.Buffer:chars(value,n(String.length(value),text("s",buffer)))
def string(value:String,buffer:B.Buffer) -> B.Buffer:string_copy(value,buffer)
def list_go(~A:Data,~encode:A -> B.Buffer -> B.Buffer,values:List<&2,A>,buffer:B.Buffer) -> B.Buffer:
  match values:
    case []:buffer
    case head <> rest:list_go(~A,~encode,rest,encode(head,buffer))
def list_copy(~A:Data,~encode:A -> B.Buffer -> B.Buffer,+values:List<&2,A>,buffer:B.Buffer) -> B.Buffer:list_go(~A,~encode,values,n(List.length(&2,A,values),text("q",buffer)))
def list(~A:Data,~encode:A -> B.Buffer -> B.Buffer,values:List<&2,A>,buffer:B.Buffer) -> B.Buffer:list_copy(~A,~encode,values,buffer)
def option(~A:Data,~encode:A -> B.Buffer -> B.Buffer,value:Maybe<&2,A>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case None{}:text("0",buffer)
    case Some{value}:encode(value,text("1",buffer))
def tree(~A:Data,~encode:A -> B.Buffer -> B.Buffer,value:V.Tree<A>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Leaf{value}:encode(value,text("l",buffer))
    case V.Branch{left,right}:tree(~A,~encode,right,tree(~A,~encode,left,text("a",buffer)))
def four(value:T.Four,buffer:B.Buffer) -> B.Buffer:
  match value:
    case T.Four{a,b,c,d}:u(d,u(c,u(b,u(a,text("f",buffer)))))
def vitals(value:V.Vitals,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Vitals{values,reserve,class}:u(class,u(reserve,tree(~U32,~u,values,text("P",buffer))))
def armor(value:V.Armor,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Armor{values,grade}:u(grade,tree(~U32,~u,values,text("V",buffer)))
def selected(value:T.Tracked,buffer:B.Buffer) -> B.Buffer:
  match value:
    case T.Tracked{group}:u(group,text("G",buffer))
def ledger(value:V.Ledger,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Ledger{values,epoch}:u(epoch,tree(~U32,~u,values,text("J",buffer)))
def ledger_view(value:T.LedgerView,buffer:B.Buffer) -> B.Buffer:
  match value:
    case T.LedgerView{values,epoch}:u(epoch,four(values,text("j",buffer)))
def key(value:Key.Key,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Key.EntityKey{index,generation}:u(generation,u(index,text("k",buffer)))
def handle(value:W.Handle<T.HealthSchema>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case W.Handle{namespace,Key.EntityKey{index,generation}}:u(generation,u(index,u(namespace,text("K",buffer))))
def phase(value:Alloc.Phase,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Alloc.Consumed{}:u(0,buffer)
    case Alloc.Pending{}:u(1,buffer)
    case Alloc.Live{}:u(2,buffer)
    case Alloc.DeadRetained{}:u(3,buffer)
    case Alloc.Free{}:u(4,buffer)
def slot(value:Alloc.Slot,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Alloc.Slot{generation,value}:phase(value,u(generation,text("z",buffer)))
def entry(value:Lifecycle.Entry,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Lifecycle.Entry{id,Lifecycle.Stamp{added,changed}}:u(changed,u(added,u(id,text("e",buffer))))
def column(~A:Data,~encode:A -> B.Buffer -> B.Buffer,value:V.Column<A>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Plain{values,stamps}:list(~Lifecycle.Entry,~entry,stamps,tree(~Maybe<&2,A>,~option(~A,~encode),values,u(0,text("C",buffer))))
    case V.Legacy{variant,value}:string(value,u(variant,text("C",buffer)))
def allocator(value:V.Allocator,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Allocator{next,high,capacity,depth,slots,free,order}:list(~Key.Key,~key,order,list(~U32,~u,free,tree(~Alloc.Slot,~slot,slots,n(depth,u(capacity,u(high,u(next,text("A",buffer))))))))
def registration(value:W.RegistrationMeta,buffer:B.Buffer) -> B.Buffer:
  match value:
    case W.RegistrationMeta{id,name,access}:list(~String,~string,access,string(name,u(id,text("g",buffer))))
def unit(value:Unit,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Unit{}:text("0",buffer)
def world(value:V.World,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.World{namespace,allocation,V.Store{main,aux,flag},resource,sibling,events,count,kinds,registrations,nextSystem,clock}:u(clock,u(nextSystem,list(~W.RegistrationMeta,~registration,registrations,list(~U32,~u,kinds,n(count,list(~Nat,~n,events,unit(sibling,ledger(resource,column(~T.Tracked,~selected,flag,column(~V.Armor,~armor,aux,column(~V.Vitals,~vitals,main,allocator(allocation,u(namespace,text("W",buffer))))))))))))))
def local(value:V.Local,buffer:B.Buffer) -> B.Buffer:
  match value:
    case V.Local{namespace,id,name,access,owner}:tree(~U32,~u,owner,list(~String,~string,access,string(name,u(id,u(namespace,text("L",buffer))))))
def error(value:W.WorldError,buffer:B.Buffer) -> B.Buffer:
  match value:
    case W.MissingEntity{}:u(0,buffer)
    case W.CapacityExceeded{}:u(1,buffer)
    case W.NamespaceExhausted{}:u(2,buffer)
    case W.SystemIdExhausted{}:u(3,buffer)
def reservation(value:W.Reservation<T.HealthSchema>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case W.Reserved{entity}:handle(entity,u(0,text("h",buffer)))
    case W.ReservationRejected{reason}:error(reason,u(1,text("h",buffer)))
def outcome(value:Tx.Outcome<Unit>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Tx.Success{}:u(0,text("E",buffer))
    case Tx.Failure{Unit{}}:u(1,text("E",buffer))
def vitals_view(value:T.VitalsView,buffer:B.Buffer) -> B.Buffer:
  match value:
    case T.VitalsView{values,reserve,class}:u(class,u(reserve,four(values,text("p",buffer))))
def armor_view(value:T.ArmorView,buffer:B.Buffer) -> B.Buffer:
  match value:
    case T.ArmorView{values,grade}:u(grade,four(values,text("v",buffer)))
def access(~A:Data,~encode:A -> B.Buffer -> B.Buffer,value:Cmp.Access<A>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Cmp.Found{value}:encode(value,u(0,buffer))
    case Cmp.ComponentAbsent{}:u(1,buffer)
    case Cmp.MissingEntity{}:u(2,buffer)
def row(value:IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,buffer:B.Buffer) -> B.Buffer:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:access(~T.Tracked,~selected,flag,access(~T.ArmorView,~armor_view,aux,access(~T.VitalsView,~vitals_view,main,handle(entity,text("r",buffer)))))
def frame(value:D.Frame,buffer:B.Buffer) -> B.Buffer:
  match value:
    case D.Frame{count,iteration,phase,target,pending,foreign,stale,reservations}:list(~W.Reservation<T.HealthSchema>,~reservation,reservations,list(~W.Handle<T.HealthSchema>,~handle,stale,handle(foreign,option(~W.Handle<T.HealthSchema>,~handle,pending,option(~W.Handle<T.HealthSchema>,~handle,target,u(phase,u(iteration,u(count,text("F",buffer)))))))))
def seen(value:D.Seen,buffer:B.Buffer) -> B.Buffer:
  match value:
    case D.Seen{entity,kind}:u(kind,handle(entity,text("d",buffer)))
def boundary(value:D.Boundary,buffer:B.Buffer) -> B.Buffer:
  match value:
    case D.Boundary{args,rows,resource,lookups,stale,before,after}:world(after,world(before,list(~D.Seen,~seen,stale,four(lookups,ledger_view(resource,list(~IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,~row,rows,frame(args,text("B",buffer))))))))
def output(value:D.Output,buffer:B.Buffer) -> B.Buffer:
  match value:
    case D.Output{args,value}:option(~D.Boundary,~boundary,value,frame(args,text("O",buffer)))
def operation(value:D.Operation,buffer:B.Buffer) -> B.Buffer:
  match value:
    case D.Select{}:u(0,buffer)
    case D.Reserve{}:u(1,buffer)
    case D.Dispose{}:u(2,buffer)
    case D.Observe{}:u(3,buffer)
def call_status(value:S.CallStatus,buffer:B.Buffer) -> B.Buffer:
  match value:
    case S.Succeeded{}:u(0,buffer)
    case S.Failed{}:u(1,buffer)
    case S.Refused{}:u(2,buffer)
def call(value:S.Call,buffer:B.Buffer) -> B.Buffer:
  match value:
    case S.Call{kind,id,status,owner,returned}:option(~D.Output,~output,returned,local(owner,call_status(status,u(id,operation(kind,text("R",buffer))))))
def status(value:Program.Status,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Program.Complete{}:u(0,buffer)
    case Program.BodyFailed{}:u(1,buffer)
    case Program.Refused{}:u(2,buffer)
    case Program.Invalid{}:u(3,buffer)
def step(value:Sch.Step,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Sch.System{id,condition}:u(condition,u(id,u(0,buffer)))
    case Sch.Phase{name}:string(name,u(1,buffer))
    case Sch.Barrier{}:u(2,buffer)
def observation(value:Sch.Observation,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Sch.Entered{name}:string(name,u(0,buffer))
    case Sch.Ran{id}:u(id,u(1,buffer))
    case Sch.Skipped{id}:u(id,u(2,buffer))
    case Sch.Applied{}:u(3,buffer)
def log(value:Program.Log,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Program.Log{name,steps,result,observations}:option(~List<&2,Sch.Observation>,~list(~Sch.Observation,~observation),observations,status(result,list(~Sch.Step,~step,steps,string(name,text("t",buffer)))))
def ids(value:Program.Ids,buffer:B.Buffer) -> B.Buffer:
  match value:
    case Program.Ids{s,r,d,o}:u(o,u(d,u(r,u(s,buffer))))
