import Base
import fixture-format.bend as F
import fixture-phase.bend as Phase
import fixture-snapshot.bend as Snap
import fixture-matrix.bend as Matrix
import ../../selection.bend as Select
import ../../query.bend as Query
import ../../core-v1/src/ecs/component.bend as C
import ../../core-v1/src/ecs/relation-query.bend as RQ
import ../../core-v1/src/ecs/world.bend as W

def stocks(~S:Data,rows:List<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> List<&2,U32>:
  match rows:
    case []:[]
    case Query.Row{_,Select.Product{Select.Product{C.Found{value},_},_}} <> rest:value <> stocks(~S,rest)
    case _ <> rest:stocks(~S,rest)
def titles(~S:Data,rows:List<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> List<&2,String>:
  match rows:
    case []:[]
    case Query.Row{_,Select.Product{Select.Product{_,C.Found{value}},_}} <> rest:value <> titles(~S,rest)
    case _ <> rest:titles(~S,rest)
def quoted(value:String) -> String:
  "\"" ++ value ++ "\""
def owners(~S:Data,snapshot:Snap.Snapshot<S>) -> String:
  match snapshot:
    case Snap.Snapshot{Snap.Metadata{_,_,_,Snap.ResourceValues{a,b}},+rows}:"{\"stock\":" ++ List.show(&2,U32,U32.show,stocks(~S,rows)) ++ ",\"title\":" ++ List.show(&2,String,quoted,titles(~S,rows)) ++ ",\"resources\":[[" ++ U32.show(a) ++ "],[" ++ U32.show(b) ++ "] ]}"
def clock(~S:Data,snapshot:Snap.Snapshot<S>) -> U32:
  match snapshot:
    case Snap.Snapshot{Snap.Metadata{_,clock,_,_},_}:clock
def pending(~S:Data,snapshot:Snap.Snapshot<S>) -> U32:
  match snapshot:
    case Snap.Snapshot{Snap.Metadata{_,_,pending,_},_}:pending
def namespace(~S:Data,snapshot:Snap.Snapshot<S>) -> U32:
  match snapshot:
    case Snap.Snapshot{Snap.Metadata{namespace,_,_,_},_}:namespace
def entry_items(~S:Data,+namespace:U32,values:List<&2,Matrix.Entry<S>>) -> String:
  match values:
    case []:""
    case value <> []:F.entry(~S,namespace,value)
    case value <> rest:F.entry(~S,namespace,value) ++ "," ++ entry_items(~S,namespace,rest)
def entries(~S:Data,namespace:U32,values:List<&2,Matrix.Entry<S>>) -> String:
  "[" ++ entry_items(~S,namespace,values) ++ "]"
def phase(~S:Data,label:String,value:Phase.Phase<S>) -> String:
  match value:
    case Phase.Phase{+before,+after,queries}:"{\"phase\":\"" ++ label ++ "\",\"pending\":" ++ U32.show(pending(~S,before)) ++ ",\"queries\":" ++ entries(~S,namespace(~S,before),queries) ++ ",\"worldClockBefore\":" ++ U32.show(clock(~S,before)) ++ ",\"worldClockAfter\":" ++ U32.show(clock(~S,after)) ++ ",\"ownersBefore\":" ++ owners(~S,before) ++ ",\"ownersAfter\":" ++ owners(~S,after) ++ "}"
def incoming_cells(~S:Data,cells:List<&2,RQ.Cell<S>>) -> List<&2,W.Handle<S>>:
  match cells:
    case []:[]
    case RQ.Cell{_,RQ.Incoming{},RQ.Sources{handles}} <> _:handles
    case RQ.Cell{_,RQ.Incoming{},RQ.Missing{}} <> _:[]
    case _ <> rest:incoming_cells(~S,rest)
def chosen(~S:Data,value:Bool,handles:List<&2,W.Handle<S>>,next:Unit -> List<&2,W.Handle<S>>) -> List<&2,W.Handle<S>>:
  match value:
    case True{}:handles
    case False{}:next(Unit{})
def inverse_rows(~S:Data,+target:U32,rows:List<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> List<&2,W.Handle<S>>:
  match rows:
    case []:[]
    case Query.Row{W.Handle{_,id},Select.Product{_,cells}} <> rest:chosen(~S,U32.is_eq(target,id),incoming_cells(~S,cells),_ => inverse_rows(~S,target,rest))
def inverse(~S:Data,target:U32,value:Phase.Phase<S>) -> String:
  match value:
    case Phase.Phase{_,Snap.Snapshot{_,rows},_}:List.show(&2,W.Handle<S>,F.ids(~S),inverse_rows(~S,target,rows))
