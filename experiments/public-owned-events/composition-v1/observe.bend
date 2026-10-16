import Base
import ./fixture.bend as F
import ../ordinary-v1/observe.bend as R
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-storage.bend as Storage

def number(value:U32) -> U32 & String:
  match value:
    case +value:(value,U32.show(value))
def optional(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some(" ++ value ++ ")"
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{a,c}:"(" ++ U32.show(a) ++ "," ++ U32.show(c) ++ ")"
def stamped(~S:Data,text:String,result:Col.Column<S,U32> & Life.Stamp) -> Col.Column<S,U32> & String:
  (column,ticks) = result
  (column,text ++ "@" ++ stamp(ticks))
def viewed(~S:Data,+id:U32,result:Col.Column<S,U32> & Maybe<&2,String>) -> Col.Column<S,U32> & String:
  (column,value) = result
  stamped(~S,"row" ++ U32.show(id) ++ "=" ++ optional(value),Col.lifecycle(~S,~U32,column,id))
def cell(~S:Data,+id:U32,column:Col.Column<S,U32>) -> Col.Column<S,U32> & String:
  viewed(~S,id,Col.view(~S,~U32,~String,~number,column,id))
def rows_join(~S:Data,text:String,result:Col.Column<S,U32> & String) -> Col.Column<S,U32> & String:
  (column,tail) = result
  (column,text ++ ";" ++ tail)
def rows_next(~S:Data,next:Col.Column<S,U32> -> Col.Column<S,U32> & String,result:Col.Column<S,U32> & String) -> Col.Column<S,U32> & String:
  (column,text) = result
  rows_join(~S,text,next(column))
def rows(~S:Data,ids:List<&2,U32>,column:Col.Column<S,U32>) -> Col.Column<S,U32> & String:
  match ids:
    case []:(column,"")
    case id <> tail:rows_next(~S,c => rows(~S,tail,c),cell(~S,id,column))
def resources_done(+counter:U32,value:Log.Log<Array<U32>> & String) -> Storage.Resources<U32,Array<U32>> & String:
  (log,text) = value
  (Storage.Resources{counter,log},"counter=" ++ U32.show(counter) ++ "," ++ text)
def resources(value:Storage.Resources<U32,Array<U32>>) -> Storage.Resources<U32,Array<U32>> & String:
  match value:
    case Storage.Resources{counter,log}:resources_done(counter,R.log(log))
def world_done(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Nat>,pending:List<(F.World(~S) -> F.World(~S))>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,+count:U32,a:Array<Bool> & String,b:Col.Column<S,U32> & String,c:Storage.Resources<U32,Array<U32>> & String) -> F.World(~S) & String:
  match a b c:
    case (live,lt),(column,ct),(resource,rt):(W.World{ns,next,high,live,capacity,depth,column,resource,events,pending,regs,sid,clock},"world(ns=" ++ U32.show(ns) ++ ",next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",live=" ++ lt ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",column={" ++ ct ++ "}," ++ rt ++ ",events=" ++ List.show(~&2,~Nat,~R.nat,events) ++ ",pending=" ++ U32.show(count) ++ ",regs=" ++ List.show(~&2,~W.RegistrationMeta,~R.meta,regs) ++ ",sid=" ++ U32.show(sid) ++ ",clock=" ++ U32.show(clock) ++ ")")
def world_raw(~S:Data,count:U32,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{+ns,+next,+high,live,+capacity,+depth,column,resource,+events,pending,+regs,+sid,+clock}:world_done(~S,ns,next,high,capacity,depth,events,pending,regs,sid,clock,count,R.live(live),rows(~S,[1,2,3,4],column),resources(resource))
def world_counted(~S:Data,value:F.World(~S) & U32) -> F.World(~S) & String:
  (world,count) = value
  world_raw(~S,count,world)
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:world_counted(~S,W.pending_count(~S,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,value))
def registry(~S:Data,value:F.Registry(~S)) -> F.Registry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"registry(ns=" ++ U32.show(ns) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def payloads(value:List<Array<U32>>) -> String:R.payloads(value)
def values(value:List<&2,U32>) -> String:List.show(~&2,~U32,~U32.show,value)
