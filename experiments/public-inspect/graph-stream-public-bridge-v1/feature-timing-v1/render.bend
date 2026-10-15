import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/relation-query.bend as RQ
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/inspector-query-projection.bend as Q

# Only closed fixture labels enter quoted; no user strings are serialized here.
def quoted(text:String) -> String: "\"" ++ text ++ "\""
def strings(items:List<&2,String>) -> List<&2,String>:
  match items:
    case []:[]
    case item <> rest:quoted(item) <> strings(rest)
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def tail(items:List<&2,String>) -> String:
  match items:
    case []:""
    case item <> rest:"," ++ item ++ tail(rest)
def contents(items:List<&2,String>) -> String:
  match items:
    case []:""
    case item <> rest:item ++ tail(rest)
def array(items:List<&2,String>) -> String: "[" ++ contents(items) ++ "]"
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{_,id}:U32.show(id)
def handles(~S:Data,values:List<&2,W.Handle<S>>) -> List<&2,String>:
  match values:
    case []:[]
    case value <> rest:handle(~S,value) <> handles(~S,rest)
def value(~S:Data,item:RQ.Value<S>) -> String:
  match item:
    case RQ.Missing{}:"{\"missing\":true}"
    case RQ.Target{target}:"{\"target\":" ++ handle(~S,target) ++ "}"
    case RQ.Sources{sources}:"{\"sources\":" ++ array(handles(~S,sources)) ++ "}"
def cells(~S:Data,items:List<&2,RQ.Cell<S>>) -> List<&2,String>:
  match items:
    case []:[]
    case RQ.Cell{_,_,item} <> rest:value(~S,item) <> cells(~S,rest)
def row(~S:Data,item:IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>) -> String:
  match item:
    case IQ.ProjectedRow{entity,Q.Product{_,items}}:"{\"id\":" ++ handle(~S,entity) ++ ",\"cells\":" ++ array(cells(~S,items)) ++ "}"
def rows(~S:Data,items:List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> List<&2,String>:
  match items:
    case []:[]
    case item <> rest:row(~S,item) <> rows(~S,rest)
def row_array(~S:Data,items:List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> String:
  array(rows(~S,items))
def inspect_record(schema:String,relation:String,mode:String,pass:String,result:String) -> String:
  "{\"schema\":" ++ quoted(schema) ++ ",\"operation\":\"inspect\",\"relation\":" ++ quoted(relation) ++ ",\"mode\":" ++ quoted(mode) ++ ",\"pass\":" ++ quoted(pass) ++ ",\"result\":" ++ result ++ "}"
def check_record(schema:String,relation:String,mode:String,pass:String,result:String) -> String:
  "{\"schema\":" ++ quoted(schema) ++ ",\"operation\":\"check-noop\",\"relation\":" ++ quoted(relation) ++ ",\"mode\":" ++ quoted(mode) ++ ",\"pass\":" ++ quoted(pass) ++ ",\"result\":" ++ result ++ "}"
