import Base
import ./fixture.bend as F
import ../heterogeneous-v1/schema.bend as Schema
import ../ordinary-array-v1/observe.bend as R
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/recoverable-component.bend as RC
import ../../../src/ecs/recoverable-array.bend as RA
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-recovery-system.bend as O

def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{a,c}:U32.show(a) ++ ":" ++ U32.show(c)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def slot(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"-"
    case Some{value}:value
def cell_stamped(~S:Data,~P:Type,text:String,result:Col.Column<S,P> & Life.Stamp) -> Col.Column<S,P> & String:
  (column,ticks) = result
  (column,text ++ "@" ++ stamp(ticks))
def cell_viewed(~S:Data,~P:Type,id:U32,result:Col.Column<S,P> & Maybe<&2,String>) -> Col.Column<S,P> & String:
  (column,text) = result
  cell_stamped(~S,~P,slot(text),Col.lifecycle(~S,~P,column,id))
def cell(~S:Data,~P:Type,~view:P -> P & String,+id:U32,column:Col.Column<S,P>) -> Col.Column<S,P> & String:
  cell_viewed(~S,~P,id,Col.view(~S,~P,~String,~view,column,id))
def cell_join(~S:Data,~P:Type,text:String,result:Col.Column<S,P> & String) -> Col.Column<S,P> & String:
  (column,rest) = result
  (column,text ++ ";" ++ rest)
def cell_next(~S:Data,~P:Type,next:Col.Column<S,P> -> Col.Column<S,P> & String,result:Col.Column<S,P> & String) -> Col.Column<S,P> & String:
  (column,text) = result
  cell_join(~S,~P,text,next(column))
def cells(~S:Data,~P:Type,~view:P -> P & String,ids:List<&2,U32>,column:Col.Column<S,P>) -> Col.Column<S,P> & String:
  match ids:
    case []:(column,"")
    case id <> rest:cell_next(~S,~P,c => cells(~S,~P,~view,rest,c),cell(~S,~P,~view,id,column))
def store_done(~S:Data,a:Col.Column<S,Array<Array<U32>>> & String,b:Col.Column<S,Array<U32>> & String) -> Schema.Store(~S) & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"Payload=" ++ x ++ ":Flags=" ++ y)
def store(~S:Data,value:Schema.Store(~S)) -> Schema.Store(~S) & String:
  match value:
    case Product.Owner{a,b}:store_done(~S,cells(~S,~Array<Array<U32>>,~R.array,[0,1,2,3],a),cells(~S,~Array<U32>,~R.element,[0,1,2,3],b))
def world_done(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,pending:List<(F.World(~S) -> F.World(~S))>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,count:U32,a:Schema.Store(~S) & String,b:Array<Bool> & String,c:Array<Array<U32>> & String) -> F.World(~S) & String:
  match a b c:
    case (store,st),(live,lt),(resource,rt):(W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"W{" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ lt ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "," ++ st ++ ",resource=" ++ rt ++ ",events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ",pending=" ++ U32.show(count) ++ "," ++ List.show(~&2,~W.RegistrationMeta,~R.registration,regs) ++ "," ++ U32.show(sid) ++ "," ++ U32.show(clock) ++ "}")
def world_raw(~S:Data,count:U32,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,column,resource,events,pending,regs,sid,clock}:world_done(~S,ns,next,high,capacity,depth,events,pending,regs,sid,clock,count,store(~S,column),R.tree(~Bool,~R.boolean,live),R.array(resource))
def world_counted(~S:Data,value:F.World(~S) & U32) -> F.World(~S) & String:
  (world,count) = value
  world_raw(~S,count,world)
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:world_counted(~S,W.pending_count(~S,~Schema.Store(~S),~Array<Array<U32>>,~Unit,value))
def some(~P:Type,value:P & String) -> Maybe<P> & String:
  (value,text) = value
  (Some{value},"Some:" ++ text)
def optional(~P:Type,~view:P -> P & String,value:Maybe<P>) -> Maybe<P> & String:
  match value:
    case None{}:(None{},"None")
    case Some{value}:some(~P,view(value))
def component_done(~S:Data,~P:Type,+target:W.Handle<S>,+ticks:Life.Stamp,value:Maybe<P> & String) -> RC.Record<S,P> & String:
  (value,text) = value
  (RC.Record{target,ticks,value},handle(~S,target) ++ "@" ++ stamp(ticks) ++ ":" ++ text)
def component(~S:Data,~P:Type,~view:P -> P & String,value:RC.Record<S,P>) -> RC.Record<S,P> & String:
  match value:
    case RC.Record{target,ticks,value}:component_done(~S,~P,target,ticks,optional(~P,~view,value))
def array_records_done(a:List<RA.Record<Array<U32>>> & String,b:List<RA.Record<Array<U32>>> & String) -> Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>> & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"captures=" ++ x ++ ":resource=" ++ y)
def array_records(value:Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>) -> Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>> & String:
  match value:
    case Product.Owner{a,b}:array_records_done(R.records(a),R.records(b))
def tail_done(~S:Data,a:List<RC.Record<S,Array<U32>>> & String,b:Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>> & String) -> Product.Owner<List<RC.Record<S,Array<U32>>>,Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>> & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"Flags=" ++ x ++ ":" ++ y)
def tail(~S:Data,value:Product.Owner<List<RC.Record<S,Array<U32>>>,Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>>) -> Product.Owner<List<RC.Record<S,Array<U32>>>,Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>> & String:
  match value:
    case Product.Owner{a,b}:tail_done(~S,R.items(~RC.Record<S,Array<U32>>,~component(~S,~Array<U32>,~R.element),a),array_records(b))
def recovery_done(~S:Data,a:List<RC.Record<S,Array<Array<U32>>>> & String,b:Product.Owner<List<RC.Record<S,Array<U32>>>,Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>> & String) -> F.Recovery(~S) & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"Payload=" ++ x ++ ":" ++ y)
def recovery(~S:Data,value:F.Recovery(~S)) -> F.Recovery(~S) & String:
  match value:
    case Product.Owner{a,b}:recovery_done(~S,R.items(~RC.Record<S,Array<Array<U32>>>,~component(~S,~Array<Array<U32>>,~R.array),a),tail(~S,b))
def owner_done(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,value:Array<Array<U32>> & String) -> F.Instance(~S) & String:
  (capture,text) = value
  (O.Owner{Sys.Registry{ns,id,name,access,cursor},capture},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~R.text,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":capture=" ++ text)
def owner(~S:Data,value:F.Instance(~S)) -> F.Instance(~S) & String:
  match value:
    case O.Owner{Sys.Registry{ns,id,name,access,cursor},capture}:owner_done(~S,ns,id,name,access,cursor,R.array(capture))
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def error_shared(+value:W.WorldError) -> W.WorldError & String:(value,error(value))
def error_owner(value:W.WorldError) -> W.WorldError & String:error_shared(value)
def output_done(a:List<Maybe<Array<Array<U32>>>> & String,b:List<Maybe<Array<U32>>> & String,c:List<Array<Array<U32>>> & String,d:List<Array<U32>> & String,e:List<W.WorldError> & String) -> F.Output & String:
  match a b c d e:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et):(F.Output{a,b,c,d,e},"Payload=" ++ at ++ ":Flags=" ++ bt ++ ":arrays=" ++ ct ++ ":elements=" ++ dt ++ ":errors=" ++ et)
def output(value:F.Output) -> F.Output & String:
  match value:
    case F.Output{a,b,c,d,e}:output_done(R.items(~Maybe<Array<Array<U32>>>,~optional(~Array<Array<U32>>,~R.array),a),R.items(~Maybe<Array<U32>>,~optional(~Array<U32>,~R.element),b),R.items(~Array<Array<U32>>,~R.array,c),R.items(~Array<U32>,~R.element,d),R.items(~W.WorldError,~error_owner,e))
def args_done(~S:Data,+target:W.Handle<S>,a:Array<Array<U32>> & String,b:Array<U32> & String,c:Array<Array<U32>> & String,d:Array<U32> & String,e:Array<Array<U32>> & String,f:Array<U32> & String,g:Array<Array<U32>> & String,h:Array<U32> & String,i:Array<Array<U32>> & String,+fail:Bool) -> F.Args<S> & String:
  match a b c d e f g h i:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et),(f,ft),(g,gt),(h,ht),(i,it):(F.Args{target,a,b,c,d,e,f,g,h,i,fail},"target=" ++ handle(~S,target) ++ ":a=" ++ at ++ ":b=" ++ bt ++ ":a2=" ++ ct ++ ":b2=" ++ dt ++ ":capture=" ++ et ++ ":element=" ++ ft ++ ":resourceFirst=" ++ gt ++ ":resourceElement=" ++ ht ++ ":resourceSecond=" ++ it ++ ":fail=" ++ Bool.show(fail))
def args(~S:Data,value:F.Args<S>) -> F.Args<S> & String:
  match value:
    case F.Args{target,a,b,c,d,e,f,g,h,i,fail}:args_done(~S,target,R.array(a),R.element(b),R.array(c),R.element(d),R.array(e),R.element(f),R.array(g),R.element(h),R.array(i),fail)
