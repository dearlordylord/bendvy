import Base
import ./fixture.bend as F
import ./resource.bend as Resource
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/ordinary-capture-query.bend as O
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/compose.bend as Q
def tree(value:P.Tree) -> String:
  match value:
    case P.Leaf{x}:U32.show(x)
    case P.Node{a,b}:"(" ++ tree(a) ++ "," ++ tree(b) ++ ")"
def pack(value:P.Observation) -> String:
  match value:
    case P.Observation{a,b}:"{" ++ tree(a) ++ ";" ++ tree(b) ++ "}"
def text(value:String) -> String:
  value
def unit(value:Unit) -> String:
  "Unit"
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access)
def slot(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"-"
    case Some{v}:U32.show(v)
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{a,c}:U32.show(a) ++ ":" ++ U32.show(c)
def stamped(~S:Data,text:String,result:Col.Column<S,U32> & Life.Stamp) -> Col.Column<S,U32> & String:
  (column,value) = result
  (column,text ++ "@" ++ stamp(value))
def viewed(~S:Data,id:U32,result:Col.Column<S,U32> & Maybe<&2,U32>) -> Col.Column<S,U32> & String:
  (column,value) = result
  stamped(~S,slot(value),Col.lifecycle(~S,~U32,column,id))
def cell(~S:Data,column:Col.Column<S,U32>,+id:U32) -> Col.Column<S,U32> & String:
  viewed(~S,id,Col.view(~S,~U32,~U32,~F.view,column,id))
def cell_join(~S:Data,text:String,result:Col.Column<S,U32> & String) -> Col.Column<S,U32> & String:
  (column,rest) = result
  (column,text ++ ";" ++ rest)
def cell_done(~S:Data,next:Col.Column<S,U32> -> Col.Column<S,U32> & String,result:Col.Column<S,U32> & String) -> Col.Column<S,U32> & String:
  (column,text) = result
  cell_join(~S,text,next(column))
def cells(~S:Data,ids:List<&2,U32>,column:Col.Column<S,U32>) -> Col.Column<S,U32> & String:
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
def world_finish(~S:Data,pendingCount:U32,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+resource:U32,+events:List<&2,Unit>,pending:List<(W.World<S,Col.Column<S,U32>,U32,Unit> -> W.World<S,Col.Column<S,U32>,U32,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,column:Col.Column<S,U32>,ctext:String,observed:Array<Bool> & String) -> W.World<S,Col.Column<S,U32>,U32,Unit> & String:
  (alive,ltext) = observed
  (W.World{ns,next,high,alive,capacity,depth,column,resource,events,pending,regs,sid,clock},"W{" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ ltext ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "," ++ ctext ++ "," ++ U32.show(resource) ++ "," ++ List.show(~&2,~Unit,~unit,events) ++ "," ++ "pending=" ++ U32.show(pendingCount) ++ "," ++ List.show(~&2,~W.RegistrationMeta,~registration,regs) ++ "," ++ U32.show(sid) ++ "," ++ U32.show(clock) ++ "}")
def world_cells(~S:Data,pendingCount:U32,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,resource:U32,+events:List<&2,Unit>,pending:List<(W.World<S,Col.Column<S,U32>,U32,Unit> -> W.World<S,Col.Column<S,U32>,U32,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,alive:Array<Bool>,observed:Col.Column<S,U32> & String) -> W.World<S,Col.Column<S,U32>,U32,Unit> & String:
  (column,text) = observed
  world_finish(~S,pendingCount,ns,next,high,capacity,depth,resource,events,pending,regs,sid,clock,column,text,live(alive))
def world_raw(~S:Data,pendingCount:U32,value:W.World<S,Col.Column<S,U32>,U32,Unit>) -> W.World<S,Col.Column<S,U32>,U32,Unit> & String:
  match value:
    case W.World{+ns,+next,+high,alive,+capacity,+depth,column,resource,+events,pending,+regs,+sid,+clock}:world_cells(~S,pendingCount,ns,next,high,capacity,depth,resource,events,pending,regs,sid,clock,alive,cells(~S,[0,1,2,3],column))
def owner_done(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,observed:P.Pack & P.Observation) -> F.Owned(S) & String:
  (capture,value) = observed
  (O.Owner{L.Instance{ns,id,name,access,capture},cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":" ++ pack(value))
def owner(~S:Data,value:F.Owned(S)) -> F.Owned(S) & String:
  match value:
    case O.Owner{L.Instance{+ns,+id,+name,+access,capture},+cursor}:owner_done(~S,ns,id,name,access,cursor,P.project(capture))
def world_counted(~S:Data,observed:W.World<S,Col.Column<S,U32>,U32,Unit> & U32) -> W.World<S,Col.Column<S,U32>,U32,Unit> & String:
  (value,count) = observed
  world_raw(~S,count,value)
def world(~S:Data,value:W.World<S,Col.Column<S,U32>,U32,Unit>) -> W.World<S,Col.Column<S,U32>,U32,Unit> & String:
  world_counted(~S,W.pending_count(~S,~Col.Column<S,U32>,~U32,~Unit,value))

def resource_owner_done(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,observed:Array<U32> & P.Tree) -> Resource.Instance(S) & String:
  (capture,value) = observed
  (L.Instance{ns,id,name,access,capture},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":" ++ tree(value))
def resource_owner(~S:Data,value:Resource.Instance(S)) -> Resource.Instance(S) & String:
  match value:
    case L.Instance{+ns,+id,+name,+access,capture}:resource_owner_done(~S,ns,id,name,access,P.observe(capture))
