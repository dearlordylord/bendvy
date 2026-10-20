import Base
import ../../../../src/ecs/change-tick.bend as Tick
import common.bend as C
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-scans.bend as Scans
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-logical.bend as Logical
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/render.bend as JSON
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/compose.bend as Q
# Exact existing failure-quiet-codec mix/fold, independent of its obsolete types.
def mix(acc:U32,value:U32) -> U32:U32.add(U32.mul(acc,33),value)
def fold(values:List<&2,U32>,acc:U32) -> U32:
  match values:
    case []:acc
    case head <> tail:fold(tail,mix(acc,head))
def prepend(values:List<&2,U32>,suffix:List<&2,U32>) -> List<&2,U32>:
  match values:
    case []:suffix
    case head <> rest:prepend(rest,head <> suffix)
def cat(left:List<&2,U32>,right:List<&2,U32>) -> List<&2,U32>:prepend(List.reverse(&2,U32,left),right)
def four(value:T.Four) -> List<&2,U32>:
  match value:
    case T.Four{a,b,c,d}:[a,b,c,d]
def boolean(value:Bool) -> U32:
  match value:
    case False{}:0
    case True{}:1
def position(value:T.PositionView) -> List<&2,U32>:
  match value:
    case T.PositionView{values,frame}:cat(four(values),[frame])
def velocity(value:T.VelocityView) -> List<&2,U32>:
  match value:
    case T.VelocityView{values,moving}:cat(four(values),[boolean(moving)])
def selected(value:T.Selected) -> List<&2,U32>:
  match value:
    case T.Selected{group}:[group]
def access(~A:Data,~encode:A -> List<&2,U32>,value:Cmp.Access<A>) -> List<&2,U32>:
  match value:
    case Cmp.MissingEntity{}:[0]
    case Cmp.ComponentAbsent{}:[1]
    case Cmp.Found{value}:2 <> encode(value)
def natural_chars(value:String) -> List<&2,U32>:
  match value:
    case SNil{}:[0]
    case SCon{head,tail}:Char.to_u32(head) <> natural_chars(tail)
def natural(value:Nat) -> List<&2,U32>:natural_chars(Nat.show(value))
def entity(value:W.Handle<T.MotionSchema>) -> Nat:
  match value:
    case W.Handle{_,Key.EntityKey{index,_}}:U32.to_nat(index)
def row(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> List<&2,U32>:
  match value:
    case IQ.ProjectedRow{handle,Projection.Product{main,Projection.Product{aux,flag}}}:cat(natural(entity(handle)),cat(access(~T.PositionView,~position,main),cat(access(~T.VelocityView,~velocity,aux),access(~T.Selected,~selected,flag))))
def list_body(~A:Data,~encode:A -> List<&2,U32>,values:List<&2,A>) -> List<&2,U32>:
  match values:
    case []:[]
    case head <> rest:cat(encode(head),list_body(~A,~encode,rest))
def list(~A:Data,~encode:A -> List<&2,U32>,+values:List<&2,A>) -> List<&2,U32>:cat(natural(List.length(&2,A,values)),list_body(~A,~encode,values))
def number(value:U32) -> List<&2,U32>:[value]
def ledger(value:T.LedgerView) -> List<&2,U32>:
  match value:
    case T.LedgerView{values,epoch}:cat(four(values),[epoch])
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
def scan(value:Scans.Scan) -> List<&2,U32>:
  match value:
    case Scans.Scan{rows,+included,score}:cat(list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,rows),cat(list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,included),[U32.sub(score,delta_rows(included,1))]))
def scans(+value:Scans.Results) -> List<&2,U32>:
  match value:
    case Scans.Results{all,present,absent,weighted}:cat(scan(all),cat(scan(present),cat(scan(absent),[U32.sub(weighted,weighted_delta(value))])))
def audit(+value:Driver.Audit,+prior:U32) -> List<&2,U32>:
  match value:
    case Driver.Audit{values,total,count,+observed,cumulative}:cat(list(~U32,~number,values),total <> cat(natural(count),cat(scans(observed),[U32.sub(cumulative,U32.add(prior,weighted_delta(observed)))])))
def audit_delta(value:Driver.Audit) -> U32:
  match value:
    case Driver.Audit{_,_,_,observed,_}:weighted_delta(observed)
def all_delta(values:List<&2,Driver.Audit>) -> U32:
  match values:
    case []:0
    case head <> rest:U32.add(audit_delta(head),all_delta(rest))
def audit_body(values:List<&2,Driver.Audit>,+prior:U32) -> List<&2,U32>:
  match values:
    case []:[]
    case +head <> rest:cat(audit(head,prior),audit_body(rest,U32.add(prior,audit_delta(head))))
def world_error(value:W.WorldError) -> U32:
  match value:
    case W.MissingEntity{}:0
    case W.CapacityExceeded{}:1
    case W.NamespaceExhausted{}:2
    case W.SystemIdExhausted{}:3
def error(value:Q.Error<Unit>) -> List<&2,U32>:
  match value:
    case Q.UserError{_}:[0]
    case Q.AccessError{reason}:[1,world_error(reason)]
def cursor_words(value:String) -> List<&2,U32>:
  match value:
    case SNil{}:[]
    case SCon{char,rest}:Char.to_u32(char) <> cursor_words(rest)
def status(value:Driver.Status) -> List<&2,U32>:
  match value:
    case Driver.Succeeded{}:[0]
    case Driver.Failed{reason}:1 <> error(reason)
    case Driver.Rejected{cursor}:2 <> cursor_words(Tick.cursor_show(cursor))
def encode(value:C.Common) -> List<&2,U32>:
  match value:
    case C.Common{rows,resource,+audits,statuses,cumulative}:cat(list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,rows),cat(ledger(resource),cat(cat(natural(List.length(&2,Driver.Audit,audits)),audit_body(audits,0)),cat(list(~Driver.Status,~status,statuses),[U32.sub(cumulative,all_delta(audits))]))))
def write_chunk(reversed:List<&2,String>) -> IO(Unit):IO.write(String.concat(List.reverse(&2,String,reversed)))
def write_piece(value:U32,first:Bool) -> String:
  match first:
    case True{}:U32.show(value)
    case False{}:", " ++ U32.show(value)
def write_go(values:List<&2,U32>,first:Bool,remaining:Nat,reversed:List<&2,String>) -> IO(Unit):
  match values:
    case []:IO.bind(Unit,Unit,write_chunk(reversed),_=>IO.write("]\n"))
    case value <> rest:
      match remaining:
        case 0n:IO.bind(Unit,Unit,write_chunk(reversed),_=>write_go(rest,False{},63n,[write_piece(value,first)]))
        case 1n+next:write_go(rest,False{},next,write_piece(value,first) <> reversed)
def write(prefix:String,values:List<&2,U32>) -> IO(Unit):IO.bind(Unit,Unit,IO.write(prefix ++ "["),_=>write_go(values,True{},64n,[]))
