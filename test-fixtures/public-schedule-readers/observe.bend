import Base
import schema.bend as S
import consumers.bend as C
import ../../src/ecs/component.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/reader-domains.bend as D

def stock(value: F.Access<S.StockView>) -> String:
  match value:
    case F.Found{value}: "{" ++ C.view(value) ++ "}"
    case _: "null"
def aux(value: F.Access<S.QueueView>) -> String:
  match value:
    case F.Found{S.QueueView{_,owned}}: "{\"owned\":" ++ C.numbers(owned) ++ "}"
    case _: "null"
def row_aux(+handle: W.Handle<S.Schema>,+value: F.Access<S.StockView>,observed: S.World() & F.Access<S.QueueView>) -> S.World() & String:
  (world,+q) = observed
  (world,"{\"id\":" ++ U32.show(C.id(handle)) ++ ",\"stock\":" ++ stock(value) ++ ",\"aux\":" ++ aux(q) ++ "}")
def row_stock(+handle: W.Handle<S.Schema>,observed: S.World() & F.Access<S.StockView>) -> S.World() & String:
  (world,+s) = observed
  row_aux(handle,s,S.get_queue(world,handle))
def row(world: S.World(),+handle: W.Handle<S.Schema>) -> S.World() & String:
  row_stock(handle,S.get_stock(world,handle))
def accumulate(+previous: List<&2,String>,observed: S.World() & String) -> S.World() & List<&2,String>:
  (world,+value) = observed
  (world,value <> previous)
def rows(handles: List<&2,W.Handle<S.Schema>>,observed: S.World() & List<&2,String>) -> S.World() & List<&2,String>:
  match handles:
    case []:
      (world,+previous) = observed
      (world,List.reverse(&2,String,previous))
    case +handle <> rest:
      (world,+previous) = observed
      rows(rest,accumulate(previous,row(world,handle)))
def all_handles(observed: S.World() & List<&2,W.Handle<S.Schema>>) -> S.World() & List<&2,String>:
  (world,+handles) = observed
  rows(handles,(world,[]))
def all(world: S.World()) -> S.World() & List<&2,String>:
  all_handles(W.handles(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def reader_name(id: U32) -> String:
  match id:
    case 1: "event-fast"
    case 2: "event-slow"
    case actual: "reader#" ++ U32.show(actual)
def status(value: Ev.ReaderStatus) -> String:
  match value:
    case Ev.ReaderStatus{id,_,_,unread,lagged}: "{\"name\":" ++ C.quoted(reader_name(id)) ++ ",\"unread\":" ++ Nat.show(unread) ++ ",\"lagged\":" ++ C.boolean(lagged) ++ "}"
def statuses(values: List<&2,Ev.ReaderStatus>) -> List<&2,String>:
  match values:
    case []: []
    case value <> rest: status(value) <> statuses(rest)
def event_observation(events: D.Events<S.Schema,S.Notice>) -> D.Events<S.Schema,S.Notice> & (String & String):
  match events:
    case D.Events{+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped,+values}: (D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,values},(C.numbers(C.ping_values(values)),C.array(statuses(Ev.reader_statuses(~S.Notice,List.reverse(&2,Ev.Position,positions),batches,dropped)))))
