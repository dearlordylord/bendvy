import Base
import health-app.bend as EntryApp
import motion-varint.bend as Var
import health-registration.bend as Reg
import health-domain.bend as D
import health-systems.bend as S
import health-program.bend as Program
import ../dense-runtime-v1/health.bend as F
import ../dense-runtime-v1/health-logical.bend as Logical
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/component.bend as Cmp
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query.bend as IQ
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/schedule.bend as Sch
import health-codec-values.bend as V
import motion-report-rope.bend as R
import ../dense-runtime-v1/types.bend as T
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/entity-key.bend as Key
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/entity-allocator.bend as Alloc
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/lifecycle.bend as Lifecycle
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/transaction.bend as Tx

def text(value:String) -> R.Rope:R.text(value)
def join(left:R.Rope,right:R.Rope) -> R.Rope:R.join(left,right)
def cat(values:List<&2,R.Rope>) -> R.Rope:
  match values:
    case []:R.Empty{}
    case head <> rest:join(head,cat(rest))
def u(value:U32) -> R.Rope:text(Var.u32(value))
def n(value:Nat) -> R.Rope:text(Var.nat(value))
def bool(value:Bool) -> R.Rope:
  match value:
    case False{}:text("0")
    case True{}:text("1")
def chars(value:String) -> R.Rope:
  match value:
    case SNil{}:R.Empty{}
    case SCon{head,rest}:join(u(Char.to_u32(head)),chars(rest))
def string_copy(+value:String) -> R.Rope:join(text("s"),join(n(String.length(value)),chars(value)))
def string(value:String) -> R.Rope:string_copy(value)
def list_go(~A:Data,~encode:A -> R.Rope,values:List<&2,A>) -> R.Rope:
  match values:
    case []:R.Empty{}
    case head <> rest:join(encode(head),list_go(~A,~encode,rest))
def list_copy(~A:Data,~encode:A -> R.Rope,+values:List<&2,A>) -> R.Rope:join(text("q"),join(n(List.length(&2,A,values)),list_go(~A,~encode,values)))
def list(~A:Data,~encode:A -> R.Rope,values:List<&2,A>) -> R.Rope:list_copy(~A,~encode,values)
def option(~A:Data,~encode:A -> R.Rope,value:Maybe<&2,A>) -> R.Rope:
  match value:
    case None{}:text("0")
    case Some{value}:join(text("1"),encode(value))
def tree(~A:Data,~encode:A -> R.Rope,value:V.Tree<A>) -> R.Rope:
  match value:
    case V.Leaf{value}:join(text("l"),encode(value))
    case V.Branch{left,right}:cat([text("a"),tree(~A,~encode,left),tree(~A,~encode,right)])
def four(value:T.Four) -> R.Rope:
  match value:
    case T.Four{a,b,c,d}:cat([text("f"),u(a),u(b),u(c),u(d)])
def vitals(value:V.Vitals) -> R.Rope:
  match value:
    case V.Vitals{values,reserve,class}:cat([text("P"),tree(~U32,~u,values),u(reserve),u(class)])
def armor(value:V.Armor) -> R.Rope:
  match value:
    case V.Armor{values,grade}:cat([text("V"),tree(~U32,~u,values),u(grade)])
def selected(value:T.Tracked) -> R.Rope:
  match value:
    case T.Tracked{group}:join(text("G"),u(group))
def ledger(value:V.Ledger) -> R.Rope:
  match value:
    case V.Ledger{values,epoch}:cat([text("J"),tree(~U32,~u,values),u(epoch)])
def ledger_view(value:T.LedgerView) -> R.Rope:
  match value:
    case T.LedgerView{values,epoch}:cat([text("j"),four(values),u(epoch)])
def key(value:Key.Key) -> R.Rope:
  match value:
    case Key.EntityKey{index,generation}:cat([text("k"),u(index),u(generation)])
def handle(value:W.Handle<T.HealthSchema>) -> R.Rope:
  match value:
    case W.Handle{namespace,Key.EntityKey{index,generation}}:cat([text("K"),u(namespace),u(index),u(generation)])
def phase(value:Alloc.Phase) -> R.Rope:
  match value:
    case Alloc.Consumed{}:u(0)
    case Alloc.Pending{}:u(1)
    case Alloc.Live{}:u(2)
    case Alloc.DeadRetained{}:u(3)
    case Alloc.Free{}:u(4)
def slot(value:Alloc.Slot) -> R.Rope:
  match value:
    case Alloc.Slot{generation,value}:cat([text("z"),u(generation),phase(value)])
def entry(value:Lifecycle.Entry) -> R.Rope:
  match value:
    case Lifecycle.Entry{id,Lifecycle.Stamp{added,changed}}:cat([text("e"),u(id),u(added),u(changed)])
def column(~A:Data,~encode:A -> R.Rope,value:V.Column<A>) -> R.Rope:
  match value:
    case V.Plain{values,stamps}:cat([text("C"),u(0),tree(~Maybe<&2,A>,~option(~A,~encode),values),list(~Lifecycle.Entry,~entry,stamps)])
    case V.Legacy{variant,value}:cat([text("C"),u(variant),string(value)])
def allocator(value:V.Allocator) -> R.Rope:
  match value:
    case V.Allocator{next,high,capacity,depth,slots,free,order}:cat([text("A"),u(next),u(high),u(capacity),n(depth),tree(~Alloc.Slot,~slot,slots),list(~U32,~u,free),list(~Key.Key,~key,order)])
def registration(value:W.RegistrationMeta) -> R.Rope:
  match value:
    case W.RegistrationMeta{id,name,access}:cat([text("g"),u(id),string(name),list(~String,~string,access)])
def unit(value:Unit) -> R.Rope:
  match value:
    case Unit{}:text("0")
def world(value:V.World) -> R.Rope:
  match value:
    case V.World{namespace,allocation,V.Store{main,aux,flag},resource,sibling,events,count,kinds,registrations,nextSystem,clock}:cat([text("W"),u(namespace),allocator(allocation),column(~V.Vitals,~vitals,main),column(~V.Armor,~armor,aux),column(~T.Tracked,~selected,flag),ledger(resource),unit(sibling),list(~Nat,~n,events),n(count),list(~U32,~u,kinds),list(~W.RegistrationMeta,~registration,registrations),u(nextSystem),u(clock)])
def local(value:V.Local) -> R.Rope:
  match value:
    case V.Local{namespace,id,name,access,owner}:cat([text("L"),u(namespace),u(id),string(name),list(~String,~string,access),tree(~U32,~u,owner)])
def error(value:W.WorldError) -> R.Rope:
  match value:
    case W.MissingEntity{}:u(0)
    case W.CapacityExceeded{}:u(1)
    case W.NamespaceExhausted{}:u(2)
    case W.SystemIdExhausted{}:u(3)
def reservation(value:W.Reservation<T.HealthSchema>) -> R.Rope:
  match value:
    case W.Reserved{entity}:cat([text("h"),u(0),handle(entity)])
    case W.ReservationRejected{reason}:cat([text("h"),u(1),error(reason)])
def outcome(value:Tx.Outcome<Unit>) -> R.Rope:
  match value:
    case Tx.Success{}:join(text("E"),u(0))
    case Tx.Failure{Unit{}}:join(text("E"),u(1))
def vitals_view(value:T.VitalsView) -> R.Rope:
  match value:
    case T.VitalsView{values,reserve,class}:cat([text("p"),four(values),u(reserve),u(class)])
def armor_view(value:T.ArmorView) -> R.Rope:
  match value:
    case T.ArmorView{values,grade}:cat([text("v"),four(values),u(grade)])
def access(~A:Data,~encode:A -> R.Rope,value:Cmp.Access<A>) -> R.Rope:
  match value:
    case Cmp.Found{value}:join(u(0),encode(value))
    case Cmp.ComponentAbsent{}:u(1)
    case Cmp.MissingEntity{}:u(2)
def row(value:IQ.ProjectedRow<T.HealthSchema,Logical.Value()>) -> R.Rope:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:cat([text("r"),handle(entity),access(~T.VitalsView,~vitals_view,main),access(~T.ArmorView,~armor_view,aux),access(~T.Tracked,~selected,flag)])
def frame(value:D.Frame) -> R.Rope:
  match value:
    case D.Frame{count,iteration,phase,target,pending,foreign,stale,reservations}:cat([text("F"),u(count),u(iteration),u(phase),option(~W.Handle<T.HealthSchema>,~handle,target),option(~W.Handle<T.HealthSchema>,~handle,pending),handle(foreign),list(~W.Handle<T.HealthSchema>,~handle,stale),list(~W.Reservation<T.HealthSchema>,~reservation,reservations)])
def seen(value:D.Seen) -> R.Rope:
  match value:
    case D.Seen{entity,kind}:cat([text("d"),handle(entity),u(kind)])
def boundary(value:D.Boundary) -> R.Rope:
  match value:
    case D.Boundary{args,rows,resource,lookups,stale,before,after}:cat([text("B"),frame(args),list(~IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,~row,rows),ledger_view(resource),four(lookups),list(~D.Seen,~seen,stale),world(before),world(after)])
def output(value:D.Output) -> R.Rope:
  match value:
    case D.Output{args,value}:cat([text("O"),frame(args),option(~D.Boundary,~boundary,value)])
def operation(value:D.Operation) -> R.Rope:
  match value:
    case D.Select{}:u(0)
    case D.Reserve{}:u(1)
    case D.Dispose{}:u(2)
    case D.Observe{}:u(3)
def call_status(value:S.CallStatus) -> R.Rope:
  match value:
    case S.Succeeded{}:u(0)
    case S.Failed{}:u(1)
    case S.Refused{}:u(2)
def call(value:S.Call) -> R.Rope:
  match value:
    case S.Call{kind,id,status,owner,returned}:cat([text("R"),operation(kind),u(id),call_status(status),local(owner),option(~D.Output,~output,returned)])
def owners_done(+args:D.Frame,+digest:U32,+boundaries:List<&2,D.Boundary>,+calls:List<&2,S.Call>,selected:S.Instance(~S.select_runner) & V.Local,reserved:S.Instance(~S.reserve_runner) & V.Local,disposed:S.Instance(~S.dispose_runner) & V.Local,observed:S.Instance(~S.observe_runner) & V.Local) -> S.Owners & R.Rope:
  (select,ss)=selected
  (reserve,sr)=reserved
  (dispose,sd)=disposed
  (observe,so)=observed
  (S.Owners{select,reserve,dispose,observe,args,digest,boundaries,calls},cat([text("N"),local(ss),local(sr),local(sd),local(so),frame(args),u(digest),list(~D.Boundary,~boundary,boundaries),list(~S.Call,~call,calls)]))
def owners(value:S.Owners) -> S.Owners & R.Rope:
  match value:
    case S.Owners{select,reserve,dispose,observe,args,digest,boundaries,calls}:owners_done(args,digest,boundaries,calls,S.instance(~S.select_runner,select),S.instance(~S.reserve_runner,reserve),S.instance(~S.dispose_runner,dispose),S.instance(~S.observe_runner,observe))
def status(value:Program.Status) -> R.Rope:
  match value:
    case Program.Complete{}:u(0)
    case Program.BodyFailed{}:u(1)
    case Program.Refused{}:u(2)
    case Program.Invalid{}:u(3)
def step(value:Sch.Step) -> R.Rope:
  match value:
    case Sch.System{id,condition}:cat([u(0),u(id),u(condition)])
    case Sch.Phase{name}:join(u(1),string(name))
    case Sch.Barrier{}:u(2)
def observation(value:Sch.Observation) -> R.Rope:
  match value:
    case Sch.Entered{name}:join(u(0),string(name))
    case Sch.Ran{id}:join(u(1),u(id))
    case Sch.Skipped{id}:join(u(2),u(id))
    case Sch.Applied{}:u(3)
def log(value:Program.Log) -> R.Rope:
  match value:
    case Program.Log{name,steps,result,observations}:cat([text("t"),string(name),list(~Sch.Step,~step,steps),status(result),option(~List<&2,Sch.Observation>,~list(~Sch.Observation,~observation),observations)])
def ids(value:Program.Ids) -> R.Rope:
  match value:
    case Program.Ids{s,r,d,o}:cat([u(s),u(r),u(d),u(o)])
type StateSnapshot is Data:
  StateSnapshot{world:V.World,owners:R.Rope}
def state_snapshot_done(stage:U32,main:F.World() & V.World,registered:S.Owners & R.Rope) -> F.World() & (S.Runtime() & StateSnapshot):
  (main,sw)=main
  (owners,so)=registered
  (main,(S.with_stage(stage,S.pack(owners)),StateSnapshot{sw,so}))
def state_snapshot(main:F.World(),runtime:S.Runtime(),_:Unit) -> F.World() & (S.Runtime() & StateSnapshot):
  match runtime:
    case (((select,reserve),(dispose,observe)),S.Shared{frame,digest,boundaries,calls,stage}):state_snapshot_done(stage,V.world(main),owners(S.Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}))
def state_done(+identity:Program.Ids,+namespace:U32,+logs:List<&2,Program.Log>,+result:Program.Status,main:EntryApp.Slot() & StateSnapshot,foreign:F.World() & V.World) -> Program.State & R.Rope:
  (app,StateSnapshot{sw,so})=main
  (foreign,sf)=foreign
  (Program.State{app,foreign,identity,namespace,logs,result},cat([u(namespace),ids(identity),status(result),world(sw),world(sf),so,list(~Program.Log,~log,logs)]))
def state_body(value:Program.State) -> Program.State & R.Rope:
  match value:
    case Program.State{app,foreign,identity,namespace,logs,result}:state_done(identity,namespace,logs,result,EntryApp.project(~Unit,~StateSnapshot,~state_snapshot,app,Unit{}),V.world(foreign))
def state_tagged(observed:Program.State & R.Rope) -> Program.State & R.Rope:
  (owner,value)=observed
  (owner,join(text("T"),value))
def state(value:Program.State) -> Program.State & R.Rope:state_tagged(state_body(value))
def rejected_first(observed:Array<U32> & V.Tree<U32>) -> Reg.RejectedOwners & R.Rope:
  (capture,view)=observed
  (Reg.First{capture},cat([text("x"),u(0),tree(~U32,~u,view)]))
def rejected_second(selected:S.Instance(~S.select_runner) & V.Local,captured:Array<U32> & V.Tree<U32>) -> Reg.RejectedOwners & R.Rope:
  (select,ss)=selected
  (capture,view)=captured
  (Reg.Second{select,capture},cat([text("x"),u(1),local(ss),tree(~U32,~u,view)]))
def rejected_third(selected:S.Instance(~S.select_runner) & V.Local,reserved:S.Instance(~S.reserve_runner) & V.Local,captured:Array<U32> & V.Tree<U32>) -> Reg.RejectedOwners & R.Rope:
  (select,ss)=selected
  (reserve,sr)=reserved
  (capture,view)=captured
  (Reg.Third{select,reserve,capture},cat([text("x"),u(2),local(ss),local(sr),tree(~U32,~u,view)]))
def rejected_fourth(selected:S.Instance(~S.select_runner) & V.Local,reserved:S.Instance(~S.reserve_runner) & V.Local,disposed:S.Instance(~S.dispose_runner) & V.Local,captured:Array<U32> & V.Tree<U32>) -> Reg.RejectedOwners & R.Rope:
  (select,ss)=selected
  (reserve,sr)=reserved
  (dispose,sd)=disposed
  (capture,view)=captured
  (Reg.Fourth{select,reserve,dispose,capture},cat([text("x"),u(3),local(ss),local(sr),local(sd),tree(~U32,~u,view)]))
def rejected(value:Reg.RejectedOwners) -> Reg.RejectedOwners & R.Rope:
  match value:
    case Reg.First{capture}:rejected_first(V.tree(~U32,~U32,~V.u32_value,capture))
    case Reg.Second{select,capture}:rejected_second(S.instance(~S.select_runner,select),V.tree(~U32,~U32,~V.u32_value,capture))
    case Reg.Third{select,reserve,capture}:rejected_third(S.instance(~S.select_runner,select),S.instance(~S.reserve_runner,reserve),V.tree(~U32,~U32,~V.u32_value,capture))
    case Reg.Fourth{select,reserve,dispose,capture}:rejected_fourth(S.instance(~S.select_runner,select),S.instance(~S.reserve_runner,reserve),S.instance(~S.dispose_runner,dispose),V.tree(~U32,~U32,~V.u32_value,capture))
