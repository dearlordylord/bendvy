import Base
import json.bend as J
import actors.bend as A
import subject/motion-logical.bend as Logical
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-matched-method/src/ecs/component.bend as Cmp
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-matched-method/src/ecs/entity-key.bend as Key
import /tmp/bendvy-failedtxn-matched-method/src/ecs/inspector-query.bend as IQ
import /tmp/bendvy-failedtxn-matched-method/src/ecs/inspector-query-projection.bend as Projection

type State is Data:
  State{actors:A.Actors,records:List<&2,J.Value>}
def number(value:U32) -> J.Value:J.Number{U32.to_nat(value)}
def four(value:T.Four) -> J.Value:
  match value:
    case T.Four{a,b,c,d}:J.object([J.Field{"a",number(a)},J.Field{"b",number(b)},J.Field{"c",number(c)},J.Field{"d",number(d)}])
def position(value:T.PositionView) -> J.Value:
  match value:
    case T.PositionView{values,frame}:J.object([J.Field{"coordinates",four(values)},J.Field{"frame",number(frame)}])
def velocity(value:T.VelocityView) -> J.Value:
  match value:
    case T.VelocityView{values,moving}:J.object([J.Field{"rates",four(values)},J.Field{"moving",J.Boolean{moving}}])
def selected(value:T.Selected) -> J.Value:
  match value:
    case T.Selected{group}:J.object([J.Field{"group",number(group)}])
def ledger(value:T.LedgerView) -> J.Value:
  match value:
    case T.LedgerView{values,epoch}:J.object([J.Field{"totals",four(values)},J.Field{"epoch",number(epoch)}])
def access(~V:Data,~project:V -> J.Value,value:Cmp.Access<V>) -> J.Value:
  match value:
    case Cmp.MissingEntity{}:J.object([J.Field{"kind",J.Text{"Missing"}}])
    case Cmp.ComponentAbsent{}:J.object([J.Field{"kind",J.Text{"Absent"}}])
    case Cmp.Found{value}:J.object([J.Field{"kind",J.Text{"Found"}},J.Field{"value",project(value)}])
def maybe(~V:Data,~project:V -> J.Value,value:Maybe<&2,V>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{value}:project(value)
def values(~V:Data,~project:V -> J.Value,items:List<&2,V>) -> List<&2,J.Value>:
  match items:
    case []:[]
    case head <> tail:project(head) <> values(~V,~project,tail)
def append(value:State,record:J.Value) -> State:
  match value:
    case State{actors,records}:State{actors,List.append(&2,J.Value,records,[record])}
def reference(value:State,raw:W.Handle<T.MotionSchema>) -> J.Value:
  match value:
    case State{actors,_}:A.reference(actors,raw)
def added(value:State,handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> State:
  match value handle:
    case state,None{}:state
    case State{actors,records},Some{raw}:State{A.add(raw,actors),records}
def ordinals(values:List<&2,A.Entry>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case A.Entry{_,ordinal} <> rest:J.Number{ordinal} <> ordinals(rest)
def initialized(+actors:A.Actors) -> State:
  match actors:
    case A.Actors{entries,_,_}:State{actors,[J.object([J.Field{"kind",J.Text{"SeedActors"}},J.Field{"actors",J.array(ordinals(entries))}])]}
def start(reservations:List<&2,W.Reservation<T.MotionSchema>>) -> State:initialized(A.from_seed(reservations,A.empty()))
def row(+state:State,value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> J.Value:
  match value:
    case IQ.ProjectedRow{handle,Projection.Product{main,Projection.Product{aux,flag}}}:J.object([J.Field{"actor",reference(state,handle)},J.Field{"main",access(~T.PositionView,~position,main)},J.Field{"aux",access(~T.VelocityView,~velocity,aux)},J.Field{"flag",access(~T.Selected,~selected,flag)}])
def rows(+state:State,items:Logical.Rows()) -> List<&2,J.Value>:
  match items:
    case []:[]
    case head <> rest:row(state,head) <> rows(state,rest)
def capture_counts(a:U32,b:U32) -> J.Value:J.object([J.Field{"A",number(a)},J.Field{"B",number(b)}])
def raw_entry(value:A.Entry) -> J.Value:
  match value:
    case A.Entry{W.Handle{namespace,Key.EntityKey{index,generation}},ordinal}:J.object([J.Field{"actor",J.Number{ordinal}},J.Field{"namespace",number(namespace)},J.Field{"index",number(index)},J.Field{"generation",number(generation)}])
def raw_map(value:State) -> J.Value:
  match value:
    case State{A.Actors{entries,_,_},_}:J.array(values(~A.Entry,~raw_entry,entries))
def valid(value:State) -> Bool:
  match value:
    case State{actors,_}:A.valid(actors)
