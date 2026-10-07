import Base
import ../../../../src/ecs/relation-query.bend as RQ
import ../../../../src/ecs/world.bend as W
import trace-value.bend as J

def handle_id(~S:Data,handle:W.Handle<S>) -> J.Value:
  match handle:
    case W.Handle{_,id}:J.Number{id}
def handle_ids(~S:Data,handles:List<&2,W.Handle<S>>) -> List<&2,J.Value>:
  match handles:
    case []:[]
    case handle <> rest:handle_id(~S,handle) <> handle_ids(~S,rest)
def cell_value(~S:Data,value:RQ.Value<S>) -> J.Value:
  match value:
    case RQ.Missing{}:J.Null{}
    case RQ.Target{handle}:handle_id(~S,handle)
    case RQ.Sources{handles}:J.Items{handle_ids(~S,handles)}
def cell(~S:Data,cell:RQ.Cell<S>) -> J.Value:
  match cell:
    case RQ.Cell{key,_,value}:J.Object{[J.Field{"key",J.Text{key}},J.Field{"value",cell_value(~S,value)}]}
def cells(~S:Data,values:List<&2,RQ.Cell<S>>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:cell(~S,value) <> cells(~S,rest)
def row(~S:Data,value:RQ.Row<S,List<&2,U32>>) -> J.Value:
  match value:
    case RQ.Row{handle,values,component}:J.Object{[J.Field{"id",handle_id(~S,handle)},J.Field{"component",J.Items{J.numbers(component)}},J.Field{"cells",J.Items{cells(~S,values)}}]}
def rows(~S:Data,values:List<&2,RQ.Row<S,List<&2,U32>>>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:row(~S,value) <> rows(~S,rest)
