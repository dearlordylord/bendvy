import Base
import ./fixture.bend as F
import ./schema.bend as Schema
import ../ordinary-v1/observe.bend as R
import ../composition-v1/observe.bend as C
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/event-publication.bend as Publication

def array_leaf(~P:Type,value:P & String) -> Array<P> & String:
  (value,text) = value
  (ALeaf{value},"L(" ++ text ++ ")")
def array_join(~P:Type,left:Array<P> & String,right:Array<P> & String) -> Array<P> & String:
  match left right:
    case (left,a),(right,b):(ANode{left,right},"N(" ++ a ++ "," ++ b ++ ")")
def array(~P:Type,~view:P -> P & String,value:Array<P>) -> Array<P> & String:
  match value:
    case ALeaf{value}:array_leaf(~P,view(value))
    case ANode{left,right}:array_join(~P,array(~P,~view,left),array(~P,~view,right))
def matrix(value:Array<Array<U32>>) -> Array<Array<U32>> & String:array(~Array<U32>,~R.payload,value)
def list_join(~P:Type,head:P & String,tail:List<P> & String) -> List<P> & String:
  match head tail:
    case (head,h),(tail,t):(head <> tail,h ++ ";" ++ t)
def items(~P:Type,~view:P -> P & String,value:List<P>) -> List<P> & String:
  match value:
    case []:([],"[]")
    case head <> tail:list_join(~P,view(head),items(~P,~view,tail))
def row_done(~P:Type,+id:Nat,value:P & String) -> Log.Row<P> & String:
  (value,text) = value
  (Log.Row{id,value},Nat.show(id) ++ ":" ++ text)
def row(~P:Type,~view:P -> P & String,value:Log.Row<P>) -> Log.Row<P> & String:
  match value:
    case Log.Row{id,value}:row_done(~P,id,view(value))
def log_done(~P:Type,+next:Nat,value:List<Log.Row<P>> & String) -> Log.Log<P> & String:
  (value,text) = value
  (Log.Log{next,value},"log(next=" ++ Nat.show(next) ++ ",rows=" ++ text ++ ")")
def log(~P:Type,~view:P -> P & String,value:Log.Log<P>) -> Log.Log<P> & String:
  match value:
    case Log.Log{next,rows}:log_done(~P,next,items(~Log.Row<P>,~row(~P,~view),rows))
def final_logs(a:Log.Log<Array<U32>> & String,b:Log.Log<Array<Array<U32>>> & String) -> Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"Alerts=" ++ x ++ ",Crates=" ++ y)
def logs_join(a:Log.Log<Array<U32>> & String,b:Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & String) -> Schema.Logs() & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"Cargo=" ++ x ++ "," ++ y)
def logs(value:Schema.Logs()) -> Schema.Logs() & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:logs_join(log(~Array<U32>,~R.payload,a),final_logs(log(~Array<U32>,~R.payload,b),log(~Array<Array<U32>>,~matrix,c)))
def resources_join(a:Array<U32> & String,b:Schema.Logs() & String) -> Schema.Resources() & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"user=" ++ x ++ "," ++ y)
def resources(value:Schema.Resources()) -> Schema.Resources() & String:
  match value:
    case Product.Owner{user,value}:resources_join(R.payload(user),logs(value))
def inner_publication(value:Publication.Publication<Nat,Nat>) -> String:
  match value:
    case Publication.Publication{a,b}:"Pub(first=" ++ List.show(~&2,~Nat,~R.nat,a) ++ ",second=" ++ List.show(~&2,~Nat,~R.nat,b) ++ ")"
def publication(value:Schema.E()) -> String:
  match value:
    case Publication.Publication{a,b}:"Pub(first=" ++ List.show(~&2,~Nat,~R.nat,a) ++ ",second=" ++ List.show(~&2,~Publication.Publication<Nat,Nat>,~inner_publication,b) ++ ")"
def world_done(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Schema.E()>,pending:List<(F.World(~S) -> F.World(~S))>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,+count:U32,a:Array<Bool> & String,b:Col.Column<S,U32> & String,c:Schema.Resources() & String) -> F.World(~S) & String:
  match a b c:
    case (live,lt),(column,ct),(resource,rt):(W.World{ns,next,high,live,capacity,depth,column,resource,events,pending,regs,sid,clock},"world(ns=" ++ U32.show(ns) ++ ",next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",live=" ++ lt ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",column={" ++ ct ++ "}," ++ rt ++ ",events=" ++ List.show(~&2,~Schema.E(),~publication,events) ++ ",pending=" ++ U32.show(count) ++ ",regs=" ++ List.show(~&2,~W.RegistrationMeta,~R.meta,regs) ++ ",sid=" ++ U32.show(sid) ++ ",clock=" ++ U32.show(clock) ++ ")")
def world_raw(~S:Data,count:U32,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{+ns,+next,+high,live,+capacity,+depth,column,resource,+events,pending,+regs,+sid,+clock}:world_done(~S,ns,next,high,capacity,depth,events,pending,regs,sid,clock,count,R.live(live),C.rows(~S,[1,2,3,4],column),resources(resource))
def world_counted(~S:Data,value:F.World(~S) & U32) -> F.World(~S) & String:
  (world,count) = value
  world_raw(~S,count,world)
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:world_counted(~S,W.pending_count(~S,~Col.Column<S,U32>,~Schema.Resources(),~Schema.E(),value))
def registry(~S:Data,value:F.Registry(~S)) -> F.Registry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"registry(ns=" ++ U32.show(ns) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def publisher_registry(~S:Data,value:F.PublisherRegistry(~S)) -> F.PublisherRegistry(~S) & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"publisher(ns=" ++ U32.show(ns) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(~&2,~String,~R.text,access) ++ ",cursor=" ++ U32.show(cursor) ++ ")")
def recovery_seen(a:List<Array<U32>> & String,b:List<Array<U32>> & String,c:List<Array<Array<U32>>> & String) -> String:
  match a b c:
    case (_,x),(_,y),(_,z):"recovery(Cargo=" ++ x ++ ",Alerts=" ++ y ++ ",Crates=" ++ z ++ ")"
def recovery(value:Product.Owner<List<Array<U32>>,Product.Owner<List<Array<U32>>,List<Array<Array<U32>>>>>) -> String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:recovery_seen(items(~Array<U32>,~R.payload,a),items(~Array<U32>,~R.payload,b),items(~Array<Array<U32>>,~matrix,c))
def values(value:List<&2,U32>) -> String:List.show(~&2,~U32,~U32.show,value)
