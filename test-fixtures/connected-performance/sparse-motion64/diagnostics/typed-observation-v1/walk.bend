import Base
import ../../method/common.bend as C
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-scans.bend as Scans
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-driver.bend as Driver
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-logical.bend as Logical
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../src/ecs/component.bend as Cmp
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/entity-key.bend as Key
import ../../../../../src/ecs/compose.bend as Q

def mix(acc:U32,value:U32) -> U32:U32.add(U32.mul(acc,33),value)
def radix() -> Nat:Nat.mul(65536n,65536n)
type NaturalState is Data:
  NaturalState{remaining:Nat,token:U32}
def natural_limb(acc:U32,result:Nat & Nat) -> NaturalState:
  match result:
    case (high,low):NaturalState{high,mix(acc,U32.from_nat(low))}
def natural_step(state:NaturalState) -> NaturalState:
  match state:
    case NaturalState{value,acc}:natural_limb(acc,Nat.divmod(value,radix()))
# Entry invariant remaining <= fuel; division reduces every positive remaining.
def natural_loop(fuel:Nat,state:NaturalState) -> U32:
  match fuel state:
    case _,NaturalState{0n,acc}:mix(acc,4294967295)
    case 0n,NaturalState{_,acc}:mix(acc,4294967295)
    case 1n+rest,state:natural_loop(rest,natural_step(state))
def natural_started(state:NaturalState) -> U32:
  match state:
    case NaturalState{+remaining,acc}:natural_loop(remaining,NaturalState{remaining,acc})
def natural(value:Nat,acc:U32) -> U32:natural_started(natural_step(NaturalState{value,acc}))
def four(value:T.Four,acc:U32) -> U32:
  match value:
    case T.Four{a,b,c,d}:mix(mix(mix(mix(acc,a),b),c),d)
def boolean(value:Bool) -> U32:
  match value:
    case False{}:0
    case True{}:1
def position(value:T.PositionView,acc:U32) -> U32:
  match value:
    case T.PositionView{values,frame}:mix(four(values,acc),frame)
def velocity(value:T.VelocityView,acc:U32) -> U32:
  match value:
    case T.VelocityView{values,moving}:mix(four(values,acc),boolean(moving))
def selected(value:T.Selected,acc:U32) -> U32:
  match value:
    case T.Selected{group}:mix(acc,group)
def access(~A:Data,~fold:A -> U32 -> U32,value:Cmp.Access<A>,acc:U32) -> U32:
  match value:
    case Cmp.MissingEntity{}:mix(acc,0)
    case Cmp.ComponentAbsent{}:mix(acc,1)
    case Cmp.Found{value}:fold(value,mix(acc,2))
def entity(value:W.Handle<T.MotionSchema>,acc:U32) -> U32:
  match value:
    case W.Handle{_,Key.EntityKey{index,_}}:natural(U32.to_nat(index),acc)
def row(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,acc:U32) -> U32:
  match value:
    case IQ.ProjectedRow{handle,Projection.Product{main,Projection.Product{aux,flag}}}:access(~T.Selected,~selected,flag,access(~T.VelocityView,~velocity,aux,access(~T.PositionView,~position,main,entity(handle,acc))))
def list_body(~A:Data,~fold:A -> U32 -> U32,values:List<&2,A>,acc:U32) -> U32:
  match values:
    case []:acc
    case head <> rest:list_body(~A,~fold,rest,fold(head,acc))
def list(~A:Data,~fold:A -> U32 -> U32,+values:List<&2,A>,acc:U32) -> U32:list_body(~A,~fold,values,natural(List.length(&2,A,values),acc))
def number(value:U32,acc:U32) -> U32:mix(acc,value)
def ledger(value:T.LedgerView,acc:U32) -> U32:
  match value:
    case T.LedgerView{values,epoch}:mix(four(values,acc),epoch)
def row_delta(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> U32:
  match value:
    case IQ.ProjectedRow{W.Handle{namespace,_},_}:U32.sub(namespace,1)
def delta_rows(values:Logical.Rows(),+rank:U32) -> U32:
  match values:
    case []:0
    case head <> rest:U32.add(U32.mul(rank,row_delta(head)),delta_rows(rest,U32.add(rank,1)))
def delta(value:Scans.Scan) -> U32:
  match value:
    case Scans.Scan{_,included,_}:delta_rows(included,1)
def weighted_delta(value:Scans.Results) -> U32:
  match value:
    case Scans.Results{all,present,absent,_}:U32.add(delta(all),U32.add(U32.mul(3,delta(present)),U32.mul(5,delta(absent))))
def audit_delta(value:Driver.Audit) -> U32:
  match value:
    case Driver.Audit{_,_,_,observed,_}:weighted_delta(observed)
def all_delta(values:List<&2,Driver.Audit>) -> U32:
  match values:
    case []:0
    case head <> rest:U32.add(audit_delta(head),all_delta(rest))
def scan(value:Scans.Scan,acc:U32) -> U32:
  match value:
    case Scans.Scan{rows,+included,score}:mix(list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,included,list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,rows,acc)),U32.sub(score,delta_rows(included,1)))
def scans(+value:Scans.Results,acc:U32) -> U32:
  match value:
    case Scans.Results{all,present,absent,weighted}:mix(scan(absent,scan(present,scan(all,acc))),U32.sub(weighted,weighted_delta(value)))
def audit(+value:Driver.Audit,+prior:U32,acc:U32) -> U32:
  match value:
    case Driver.Audit{values,total,count,+observed,cumulative}:mix(scans(observed,natural(count,mix(list(~U32,~number,values,acc),total))),U32.sub(cumulative,U32.add(prior,weighted_delta(observed))))
def audit_body(values:List<&2,Driver.Audit>,+prior:U32,acc:U32) -> U32:
  match values:
    case []:acc
    case +head <> rest:audit_body(rest,U32.add(prior,audit_delta(head)),audit(head,prior,acc))
def world_error(value:W.WorldError) -> U32:
  match value:
    case W.MissingEntity{}:0
    case W.CapacityExceeded{}:1
    case W.NamespaceExhausted{}:2
    case W.SystemIdExhausted{}:3
def error(value:Q.Error<Unit>,acc:U32) -> U32:
  match value:
    case Q.UserError{_}:mix(acc,0)
    case Q.AccessError{reason}:mix(mix(acc,1),world_error(reason))
def status(value:Driver.Status,acc:U32) -> U32:
  match value:
    case Driver.Succeeded{}:mix(acc,0)
    case Driver.Failed{reason}:error(reason,mix(acc,1))
    case Driver.Rejected{cursor}:mix(mix(acc,2),cursor)
def force(value:C.Common) -> U32:
  match value:
    case C.Common{rows,resource,+audits,statuses,cumulative}:mix(list(~Driver.Status,~status,statuses,audit_body(audits,0,natural(List.length(&2,Driver.Audit,audits),ledger(resource,list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,rows,0))))),U32.sub(cumulative,all_delta(audits)))
