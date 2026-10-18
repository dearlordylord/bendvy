import Base
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as Key
import json.bend as J

type Entry is Data:
  Entry{raw:W.Handle<T.HealthSchema>,ordinal:Nat}
type Actors is Data:
  Actors{entries:List<&2,Entry>,next:Nat,valid:Bool}
def empty() -> Actors:Actors{[],1n,True{}}
def equal(left:W.Handle<T.HealthSchema>,right:W.Handle<T.HealthSchema>) -> Bool:
  match left right:
    case W.Handle{ln,lk},W.Handle{rn,rk}:Bool.and(U32.is_eq(ln,rn),Key.equal(lk,rk))
def found(yes:Bool,ordinal:Nat,next:Unit -> Maybe<&2,Nat>) -> Maybe<&2,Nat>:
  match yes:
    case True{}:Some{ordinal}
    case False{}:next(Unit{})
def find(entries:List<&2,Entry>,+raw:W.Handle<T.HealthSchema>) -> Maybe<&2,Nat>:
  match entries:
    case []:None{}
    case Entry{key,ordinal} <> rest:found(equal(key,raw),ordinal,_ => find(rest,raw))
def recorded(raw:W.Handle<T.HealthSchema>,entries:List<&2,Entry>,+next:Nat,valid:Bool,prior:Maybe<&2,Nat>) -> Actors:
  match prior:
    case None{}:Actors{List.append(&2,Entry,entries,[Entry{raw,next}]),1n+next,valid}
    case Some{_}:Actors{List.append(&2,Entry,entries,[Entry{raw,next}]),1n+next,False{}}
def add(+raw:W.Handle<T.HealthSchema>,value:Actors) -> Actors:
  match value:
    case Actors{+entries,next,valid}:recorded(raw,entries,next,valid,find(entries,raw))
def reserved(value:Actors,reservation:W.Reservation<T.HealthSchema>) -> Actors:
  match reservation:
    case W.Reserved{raw}:add(raw,value)
    case W.ReservationRejected{_}:value
def from_seed(values:List<&2,W.Reservation<T.HealthSchema>>,state:Actors) -> Actors:
  match values:
    case []:state
    case head <> rest:from_seed(rest,reserved(state,head))
def raw_value(value:W.Handle<T.HealthSchema>) -> J.Value:
  match value:
    case W.Handle{namespace,Key.EntityKey{index,generation}}:J.object([J.Field{"namespace",J.Number{U32.to_nat(namespace)}},J.Field{"index",J.Number{U32.to_nat(index)}},J.Field{"generation",J.Number{U32.to_nat(generation)}}])
def reference_found(raw:W.Handle<T.HealthSchema>,value:Maybe<&2,Nat>) -> J.Value:
  match value:
    case Some{ordinal}:J.Number{ordinal}
    case None{}:J.object([J.Field{"kind",J.Text{"Unmapped"}},J.Field{"raw",raw_value(raw)}])
def reference(value:Actors,+raw:W.Handle<T.HealthSchema>) -> J.Value:
  match value:
    case Actors{entries,_,_}:reference_found(raw,find(entries,raw))
def valid(value:Actors) -> Bool:
  match value:
    case Actors{_,_,yes}:yes
