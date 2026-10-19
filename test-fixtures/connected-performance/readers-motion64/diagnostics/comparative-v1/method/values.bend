import Base
import ../../../method/json.bend as J
import actors.bend as A
import ../../../consumer/types.bend as T
import ../../../consumer/motion-logical.bend as Logical
import ../consumer/motion-domain.bend as D
import ../consumer/motion-program.bend as P
import ../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../src/ecs/world.bend as W

def u(value:U32) -> J.Value:J.Number{U32.to_nat(value)}
def four(value:T.Four) -> J.Value:
  match value:
    case T.Four{a,b,c,d}:J.array([u(a),u(b),u(c),u(d)])
def main(value:Cmp.Access<T.PositionView>) -> J.Value:
  match value:
    case Cmp.Found{T.PositionView{cells,frame}}:J.object([J.Field{"kind",J.Text{"Found"}},J.Field{"value",J.object([J.Field{"coordinates",four(cells)},J.Field{"frame",u(frame)}])}])
    case Cmp.ComponentAbsent{}:J.object([J.Field{"kind",J.Text{"Absent"}}])
    case Cmp.MissingEntity{}:J.object([J.Field{"kind",J.Text{"MissingEntity"}}])
def aux(value:Cmp.Access<T.VelocityView>) -> J.Value:
  match value:
    case Cmp.Found{T.VelocityView{cells,moving}}:J.object([J.Field{"kind",J.Text{"Found"}},J.Field{"value",J.object([J.Field{"rates",four(cells)},J.Field{"moving",J.Boolean{moving}}])}])
    case Cmp.ComponentAbsent{}:J.object([J.Field{"kind",J.Text{"Absent"}}])
    case Cmp.MissingEntity{}:J.object([J.Field{"kind",J.Text{"MissingEntity"}}])
def flag(value:Cmp.Access<T.Selected>) -> J.Value:
  match value:
    case Cmp.Found{T.Selected{group}}:J.object([J.Field{"kind",J.Text{"Found"}},J.Field{"value",J.object([J.Field{"group",u(group)}])}])
    case Cmp.ComponentAbsent{}:J.object([J.Field{"kind",J.Text{"Absent"}}])
    case Cmp.MissingEntity{}:J.object([J.Field{"kind",J.Text{"MissingEntity"}}])
def row(actors:A.Actors,value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> J.Value:
  match value:
    case IQ.ProjectedRow{handle,Projection.Product{m,Projection.Product{a,f}}}:J.object([J.Field{"actor",A.reference(actors,handle)},J.Field{"main",main(m)},J.Field{"aux",aux(a)},J.Field{"flag",flag(f)}])
def rows(+actors:A.Actors,values:Logical.Rows(),out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case head <> rest:rows(actors,rest,row(actors,head) <> out)
def ledger(value:T.LedgerView) -> J.Value:
  match value:
    case T.LedgerView{cells,epoch}:J.object([J.Field{"totals",four(cells)},J.Field{"epoch",u(epoch)}])
def handle(actors:A.Actors,value:Maybe<&2,W.Handle<T.MotionSchema>>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{raw}:A.reference(actors,raw)
def reservations(+actors:A.Actors,values:List<&2,W.Reservation<T.MotionSchema>>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case W.Reserved{raw} <> rest:reservations(actors,rest,A.reference(actors,raw) <> out)
    case W.ReservationRejected{_} <> rest:reservations(actors,rest,J.object([J.Field{"kind",J.Text{"ReservationRejected"}}]) <> out)
def status(value:P.Status) -> J.Value:
  match value:
    case P.Complete{}:J.object([J.Field{"kind",J.Text{"Complete"}}])
    case P.BodyFailed{}:J.object([J.Field{"kind",J.Text{"BodyFailed"}}])
    case P.Refused{}:J.object([J.Field{"kind",J.Text{"Refused"}}])
    case P.Invalid{}:J.object([J.Field{"kind",J.Text{"Invalid"}}])
