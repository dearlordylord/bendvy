import Base
import ./fixture.bend as F
import ./payload.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-storage.bend as Storage

def tree(value:P.Tree) -> String:
  match value:
    case P.Leaf{value}:"L(" ++ U32.show(value) ++ ")"
    case P.Node{left,right}:"N(" ++ tree(left) ++ "," ++ tree(right) ++ ")"
def payload_view(value:Array<U32> & P.Tree) -> Array<U32> & String:
  (owner,view) = value
  (owner,tree(view))
def payload(value:Array<U32>) -> Array<U32> & String:payload_view(P.view(value))
def payload_join(head:Array<U32> & String,tail:List<Array<U32>> & String) -> List<Array<U32>> & String:
  match head tail:
    case (head,h),(tail,t):(head <> tail,h ++ ";" ++ t)
def payload_rows(values:List<Array<U32>>) -> List<Array<U32>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:payload_join(payload(head),payload_rows(tail))
def payloads_done(value:List<Array<U32>> & String) -> String:
  (_,text) = value
  text
def payloads(values:List<Array<U32>>) -> String:payloads_done(payload_rows(values))

def row_join(+id:Nat,value:Array<U32> & String) -> Log.Row<Array<U32>> & String:
  (value,text) = value
  (Log.Row{id,value},Nat.show(id) ++ ":" ++ text)
def row(value:Log.Row<Array<U32>>) -> Log.Row<Array<U32>> & String:
  match value:
    case Log.Row{id,value}:row_join(id,payload(value))
def rows_join(head:Log.Row<Array<U32>> & String,tail:List<Log.Row<Array<U32>>> & String) -> List<Log.Row<Array<U32>>> & String:
  match head tail:
    case (head,h),(tail,t):(head <> tail,h ++ ";" ++ t)
def rows(values:List<Log.Row<Array<U32>>>) -> List<Log.Row<Array<U32>>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:rows_join(row(head),rows(tail))
def retired_done(value:List<Log.Row<Array<U32>>> & String) -> String:
  (_,text) = value
  text
def retired(values:List<Log.Row<Array<U32>>>) -> String:retired_done(rows(values))

def log_join(+next:Nat,value:List<Log.Row<Array<U32>>> & String) -> Log.Log<Array<U32>> & String:
  (value,text) = value
  (Log.Log{next,value},"log(next=" ++ Nat.show(next) ++ ",rows=" ++ text ++ ")")
def log(value:Log.Log<Array<U32>>) -> Log.Log<Array<U32>> & String:
  match value:
    case Log.Log{next,values}:log_join(next,rows(values))
def resource_join(value:Log.Log<Array<U32>> & String) -> Storage.Resources<Unit,Array<U32>> & String:
  (value,text) = value
  (Storage.Resources{Unit{},value},"user=Unit," ++ text)
def resources(value:Storage.Resources<Unit,Array<U32>>) -> Storage.Resources<Unit,Array<U32>> & String:
  match value:
    case Storage.Resources{Unit{},value}:resource_join(log(value))
def boolean(+value:Bool) -> Bool & String:(value,Bool.show(value))
def live_join(a:Array<Bool> & String,b:Array<Bool> & String) -> Array<Bool> & String:
  match a b:
    case (a,x),(b,y):(ANode{a,b},"N(" ++ x ++ "," ++ y ++ ")")
def live(value:Array<Bool>) -> Array<Bool> & String:
  match value:
    case ALeaf{+value}:(ALeaf{value},"L(" ++ Bool.show(value) ++ ")")
    case ANode{a,b}:live_join(live(a),live(b))
def text(value:String) -> String:value
def nat(value:Nat) -> String:Nat.show(value)
def meta(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"(" ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~text,access) ++ ")"
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Nat>,pending:List<(F.World(~S) -> F.World(~S))>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,+count:U32,a:Array<Bool> & String,b:Storage.Resources<Unit,Array<U32>> & String) -> F.World(~S) & String:
  match a b:
    case (alive,l),(resource,r):(W.World{ns,next,high,alive,capacity,depth,Unit{},resource,events,pending,regs,sid,clock},"world(" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ l ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ ",store=Unit," ++ r ++ ",events=" ++ List.show(~&2,~Nat,~nat,events) ++ ",pending=" ++ U32.show(count) ++ ",regs=" ++ List.show(~&2,~W.RegistrationMeta,~meta,regs) ++ ",sid=" ++ U32.show(sid) ++ ",clock=" ++ U32.show(clock) ++ ")")
def world_raw(~S:Data,count:U32,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{+ns,+next,+high,alive,+capacity,+depth,Unit{},resource,+events,pending,+regs,+sid,+clock}:world_join(~S,ns,next,high,capacity,depth,events,pending,regs,sid,clock,count,live(alive),resources(resource))
def world_counted(~S:Data,value:F.World(~S) & U32) -> F.World(~S) & String:
  (value,count) = value
  world_raw(~S,count,value)
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:world_counted(~S,W.pending_count(~S,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,value))
def batch(value:Ev.Batch<Nat>) -> String:
  match value:
    case Ev.Batch{tick,values}:"(" ++ Nat.show(tick) ++ "," ++ List.show(~&2,~Nat,~nat,values) ++ ")"
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:"(" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registeredAt) ++ ")"
def reader_status(value:Ev.ReaderStatus) -> String:
  match value:
    case Ev.ReaderStatus{id,cursor,registeredAt,unread,lagged}:"(" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registeredAt) ++ "," ++ Nat.show(unread) ++ "," ++ Bool.show(lagged) ++ ")"
def runtime_join(~S:Data,+ns:U32,+batches:List<&2,Ev.Batch<Nat>>,+positions:List<&2,Ev.Position>,+next:U32,+tick:Nat,+start:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,value:F.World(~S) & String) -> F.Runtime(~S) & String:
  (value,text) = value
  (Ev.Runtime{value,ns,batches,positions,next,tick,start,boundary,capacity,dropped},"runtime(ns=" ++ U32.show(ns) ++ ",batches=" ++ List.show(~&2,~Ev.Batch<Nat>,~batch,batches) ++ ",positions=" ++ List.show(~&2,~Ev.Position,~position,positions) ++ ",status=" ++ List.show(~&2,~Ev.ReaderStatus,~reader_status,Ev.reader_statuses(~Nat,positions,batches,dropped)) ++ ",next=" ++ U32.show(next) ++ ",tick=" ++ Nat.show(tick) ++ ",frameStart=" ++ Nat.show(start) ++ ",boundary=" ++ Nat.show(boundary) ++ ",capacity=" ++ Nat.show(capacity) ++ ",dropped=" ++ Nat.show(dropped) ++ "," ++ text ++ ")")
def runtime(~S:Data,value:F.Runtime(~S)) -> F.Runtime(~S) & String:
  match value:
    case Ev.Runtime{value,ns,batches,positions,next,tick,start,boundary,capacity,dropped}:runtime_join(~S,ns,batches,positions,next,tick,start,boundary,capacity,dropped,world(~S,value))
def reader(~S:Data,value:Ev.Reader<S>) -> Ev.Reader<S> & String:
  match value:
    case Ev.Reader{+ns,+id,+registry}:(Ev.Reader{ns,id,registry},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ U32.show(registry) ++ ")")
def projection(value:P.Projection) -> String:
  match value:
    case P.Projection{value,markers}:"(" ++ U32.show(value) ++ "," ++ List.show(~&2,~U32,~U32.show,markers) ++ ")"
def args_join(+fail:Bool,+values:List<&2,P.Projection>,scratch:Array<U32> & String) -> P.Args & String:
  (scratch,text) = scratch
  (P.Args{fail,values,scratch},"args(fail=" ++ Bool.show(fail) ++ ",values=" ++ List.show(~&2,~P.Projection,~projection,values) ++ ",scratch=" ++ text ++ ")")
def args(value:P.Args) -> P.Args & String:
  match value:
    case P.Args{+fail,+values,scratch}:args_join(fail,values,payload(scratch))
def publisher(~S:Data,value:F.Publisher(~S)) -> F.Publisher(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~text,access) ++ "," ++ U32.show(cursor) ++ ")")
def registry(~S:Data,value:F.Registry(~S)) -> F.Registry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"(" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(~&2,~String,~text,access) ++ "," ++ U32.show(cursor) ++ ")")
def snapshot_join(~S:Data,label:String,a:F.Runtime(~S) & String,b:F.World(~S) & String,c:F.Publisher(~S) & String,d:Ev.Reader<S> & String,e:F.Registry(~S) & String,f:Ev.Reader<S> & String,g:F.Registry(~S) & String,h:P.Args & String,i:P.Args & String) -> F.Host<S> & String:
  match a b c d e f g h i:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et),(f,ft),(g,gt),(h,ht),(i,it):(F.Host{a,b,c,d,e,f,g,h,i},label ++ "|" ++ at ++ "|foreign=" ++ bt ++ "|publisher=" ++ ct ++ "|fast=" ++ dt ++ ":" ++ et ++ "|slow=" ++ ft ++ ":" ++ gt ++ "|fastArgs=" ++ ht ++ "|slowArgs=" ++ it)
def snapshot(~S:Data,label:String,value:F.Host<S>) -> F.Host<S> & String:
  match value:
    case F.Host{a,b,c,d,e,f,g,h,i}:snapshot_join(~S,label,runtime(~S,a),world(~S,b),publisher(~S,c),reader(~S,d),registry(~S,e),reader(~S,f),registry(~S,g),args(h),args(i))
