import Base
import common.bend as C
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/test-fixtures/connected-performance/dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/dense-runtime-v1/motion-logical.bend as Logical
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/test-fixtures/connected-performance/dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/render.bend as JSON
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/inspector-query.bend as IQ
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/component.bend as Cmp
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/world.bend as W
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/entity-key.bend as Key
import ../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/compose.bend as Q
# Exact existing failure-quiet-codec mix/fold, independent of its obsolete types.
def mix(acc:U32,value:U32) -> U32:U32.add(U32.mul(acc,33),value)
def fold(values:List<&2,U32>,acc:U32) -> U32:
  match values:
    case []:acc
    case head <> tail:fold(tail,mix(acc,head))
def cat_reversed(reversed:List<&2,U32>,right:List<&2,U32>) -> List<&2,U32>:
  match reversed:
    case []:right
    case head <> rest:cat_reversed(rest,head <> right)
def cat(left:List<&2,U32>,right:List<&2,U32>) -> List<&2,U32>:cat_reversed(List.reverse(&2,U32,left),right)
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
def audit(value:Driver.Audit) -> List<&2,U32>:
  match value:
    case Driver.Audit{values,total,count}:cat(list(~U32,~number,values),total <> natural(count))
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
def status(value:Driver.Status) -> List<&2,U32>:
  match value:
    case Driver.Succeeded{}:[0]
    case Driver.Failed{reason}:1 <> error(reason)
    case Driver.Rejected{cursor}:[2,cursor]
def encode(value:C.Common) -> List<&2,U32>:
  match value:
    case C.Common{rows,resource,audits,statuses}:cat(list(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row,rows),cat(ledger(resource),cat(list(~Driver.Audit,~audit,audits),list(~Driver.Status,~status,statuses))))
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
