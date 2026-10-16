import Base
import ./fixture.bend as F
import ../ordinary-array-v1/observe.bend as R
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/ordinary-recoverable-component-capture.bend as O
import ../../../src/ecs/recoverable-component.bend as RC
import ../../../src/ecs/recoverable-array.bend as A
import ../../../src/ecs/owner-product.bend as Product
def text(value:String) -> String:
  value
def unit(value:Unit) -> String:
  "Unit"
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access)
def slot(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"-"
    case Some{v}:v
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{a,c}:U32.show(a) ++ ":" ++ U32.show(c)
def stamped(~S:Data,text:String,result:Col.Column<S,Array<Array<U32>>> & Life.Stamp) -> Col.Column<S,Array<Array<U32>>> & String:
  (column,value) = result
  (column,text ++ "@" ++ stamp(value))
def viewed(~S:Data,id:U32,result:Col.Column<S,Array<Array<U32>>> & Maybe<&2,String>) -> Col.Column<S,Array<Array<U32>>> & String:
  (column,value) = result
  stamped(~S,slot(value),Col.lifecycle(~S,~Array<Array<U32>>,column,id))
def cell(~S:Data,column:Col.Column<S,Array<Array<U32>>>,+id:U32) -> Col.Column<S,Array<Array<U32>>> & String:
  viewed(~S,id,Col.view(~S,~Array<Array<U32>>,~String,~R.array,column,id))
def cell_join(~S:Data,text:String,result:Col.Column<S,Array<Array<U32>>> & String) -> Col.Column<S,Array<Array<U32>>> & String:
  (column,rest) = result
  (column,text ++ ";" ++ rest)
def cell_done(~S:Data,next:Col.Column<S,Array<Array<U32>>> -> Col.Column<S,Array<Array<U32>>> & String,result:Col.Column<S,Array<Array<U32>>> & String) -> Col.Column<S,Array<Array<U32>>> & String:
  (column,text) = result
  cell_join(~S,text,next(column))
def cells(~S:Data,ids:List<&2,U32>,column:Col.Column<S,Array<Array<U32>>>) -> Col.Column<S,Array<Array<U32>>> & String:
  match ids:
    case []:(column,"")
    case id <> rest:cell_done(~S,(col => cells(~S,rest,col)),cell(~S,column,id))
def live_join(a:Array<Bool> & String,b:Array<Bool> & String) -> Array<Bool> & String:
  match a b:
    case (left,x), (right,y):(ANode{left,right},"(" ++ x ++ "," ++ y ++ ")")
def live(value:Array<Bool>) -> Array<Bool> & String:
  match value:
    case ALeaf{+v}:(ALeaf{v},Bool.show(v))
    case ANode{a,b}:live_join(live(a),live(b))
def world_finish(~S:Data,pendingCount:U32,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,resource:Unit,+events:List<&2,Unit>,pending:List<(W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,column:Col.Column<S,Array<Array<U32>>>,ctext:String,observed:Array<Bool> & String) -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & String:
  (alive,ltext) = observed
  (W.World{ns,next,high,alive,capacity,depth,column,resource,events,pending,regs,sid,clock},"W{" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ ltext ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "," ++ ctext ++ ",Unit," ++ List.show(~&2,~Unit,~unit,events) ++ "," ++ "pending=" ++ U32.show(pendingCount) ++ "," ++ List.show(~&2,~W.RegistrationMeta,~registration,regs) ++ "," ++ U32.show(sid) ++ "," ++ U32.show(clock) ++ "}")
def world_cells(~S:Data,pendingCount:U32,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,resource:Unit,+events:List<&2,Unit>,pending:List<(W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,alive:Array<Bool>,observed:Col.Column<S,Array<Array<U32>>> & String) -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & String:
  (column,text) = observed
  world_finish(~S,pendingCount,ns,next,high,capacity,depth,resource,events,pending,regs,sid,clock,column,text,live(alive))
def world_raw(~S:Data,pendingCount:U32,value:W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit>) -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & String:
  match value:
    case W.World{+ns,+next,+high,alive,+capacity,+depth,column,resource,+events,pending,+regs,+sid,+clock}:world_cells(~S,pendingCount,ns,next,high,capacity,depth,resource,events,pending,regs,sid,clock,alive,cells(~S,[0,1,2,3],column))
def world_counted(~S:Data,observed:W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & U32) -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & String:
  (value,count) = observed
  world_raw(~S,count,value)
def world(~S:Data,value:W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit>) -> W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit> & String:
  world_counted(~S,W.pending_count(~S,~Col.Column<S,Array<Array<U32>>>,~Unit,~Unit,value))

def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def optional_some(value:Array<Array<U32>> & String) -> Maybe<Array<Array<U32>>> & String:
  (value,text) = value
  (Some{value},"Some:" ++ text)
def optional(value:Maybe<Array<Array<U32>>>) -> Maybe<Array<Array<U32>>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{value}:optional_some(R.array(value))
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def component_done(~S:Data,+target:W.Handle<S>,+ticks:Life.Stamp,value:Maybe<Array<Array<U32>>> & String) -> RC.Record<S,Array<Array<U32>>> & String:
  (value,text) = value
  (RC.Record{target,ticks,value},handle(~S,target) ++ "@" ++ stamp(ticks) ++ ":" ++ text)
def component(~S:Data,value:RC.Record<S,Array<Array<U32>>>) -> RC.Record<S,Array<Array<U32>>> & String:
  match value:
    case RC.Record{target,ticks,value}:component_done(~S,target,ticks,optional(value))
def recovery_done(~S:Data,a:List<RC.Record<S,Array<Array<U32>>>> & String,b:List<A.Record<Array<U32>>> & String) -> O.Recovery(~S,~Array<Array<U32>>,~Array<U32>) & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"components=" ++ x ++ ":captures=" ++ y)
def recovery(~S:Data,value:O.Recovery(~S,~Array<Array<U32>>,~Array<U32>)) -> O.Recovery(~S,~Array<Array<U32>>,~Array<U32>) & String:
  match value:
    case Product.Owner{a,b}:recovery_done(~S,R.items(~RC.Record<S,Array<Array<U32>>>,~component(~S),a),R.records(b))
def owner_done(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,value:Array<Array<U32>> & String) -> F.Instance(~S) & String:
  (capture,text) = value
  (O.Owner{Sys.Registry{ns,id,name,access,cursor},capture},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~R.text,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":capture=" ++ text)
def owner(~S:Data,value:F.Instance(~S)) -> F.Instance(~S) & String:
  match value:
    case O.Owner{Sys.Registry{ns,id,name,access,cursor},capture}:owner_done(~S,ns,id,name,access,cursor,R.array(capture))
def error_shared(+value:W.WorldError) -> W.WorldError & String:(value,error(value))
def error_owner(value:W.WorldError) -> W.WorldError & String:error_shared(value)
def output_done(a:List<Maybe<Array<Array<U32>>>> & String,b:List<Array<Array<U32>>> & String,c:List<Array<U32>> & String,errors:List<W.WorldError> & String) -> F.Output & String:
  match a b c errors:
    case (a,x),(b,y),(c,z),(errors,et):(F.Output{a,b,c,errors},"components=" ++ x ++ ":arrays=" ++ y ++ ":elements=" ++ z ++ ":errors=" ++ et)
def output(value:F.Output) -> F.Output & String:
  match value:
    case F.Output{a,b,c,errors}:output_done(R.items(~Maybe<Array<Array<U32>>>,~optional,a),R.items(~Array<Array<U32>>,~R.array,b),R.items(~Array<U32>,~R.element,c),R.items(~W.WorldError,~error_owner,errors))
def args_done(~S:Data,+target:W.Handle<S>,+foreign:W.Handle<S>,a:Array<Array<U32>> & String,b:Array<Array<U32>> & String,c:Array<Array<U32>> & String,d:Array<U32> & String,e:Array<Array<U32>> & String,f:Array<Array<U32>> & String,+fail:Bool) -> F.Args<S> & String:
  match a b c d e f:
    case (a,at),(b,bt),(c,ct),(d,dt),(e,et),(f,ft):(F.Args{target,foreign,a,b,c,d,e,f,fail},"target=" ++ handle(~S,target) ++ ":foreign=" ++ handle(~S,foreign) ++ ":first=" ++ at ++ ":second=" ++ bt ++ ":captureFirst=" ++ ct ++ ":captureElement=" ++ dt ++ ":captureSecond=" ++ et ++ ":rejected=" ++ ft ++ ":fail=" ++ Bool.show(fail))
def args(~S:Data,value:F.Args<S>) -> F.Args<S> & String:
  match value:
    case F.Args{target,foreign,a,b,c,d,e,f,fail}:args_done(~S,target,foreign,R.array(a),R.array(b),R.array(c),R.element(d),R.array(e),R.array(f),fail)
