import Base
import ../../owned-world.bend as O
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/lifecycle.bend as L

def seed_column(~S:Data,column:Col.Column<S,O.Payload>) -> Col.Column<S,O.Payload>:
  Col.restore_stamp(~S,~O.Payload,column,1,L.Stamp{7,9})
def seed_store(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>>:
  match store:
    case A.Store{O.Components{column},graph}:A.Store{O.Components{seed_column(~S,column)},graph}
def empty(~S:Data,value:Unit) -> A.Store<S,O.Components<S>>:
  seed_store(~S,O.empty(~S,value))
def stamp(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed) ++ ";"
def stamps(values:List<&2,L.Entry>) -> String:
  match values:
    case []:""
    case value <> rest:stamp(value) ++ stamps(rest)
def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverse,k}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ kind(k)
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{d,source,target}:descriptor(~S,d) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ";"
def edges(~S:Data,values:List<&2,G.Edge<S>>) -> String:
  match values:
    case []:""
    case value <> rest:edge(~S,value) ++ edges(~S,rest)
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{d,target,sources}:descriptor(~S,d) ++ ":" ++ U32.show(target) ++ ":" ++ O.show_ids(sources) ++ ";"
def inverses(~S:Data,values:List<&2,G.Inverse<S>>) -> String:
  match values:
    case []:""
    case value <> rest:inverse(~S,value) ++ inverses(~S,rest)
def graph(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{es,ivs}:"|edges=" ++ edges(~S,es) ++ "|inverseRows=" ++ inverses(~S,ivs)
def column_done(~S:Data,result:Col.Column<S,O.Payload> & String,+size:U32,+entries:List<&2,L.Entry>) -> Col.Column<S,O.Payload> & String:
  (column,text)=result
  (column,"|columnVariant=Column|columnSize=" ++ U32.show(size) ++ "|columnSlots=" ++ text ++ "|lifecycle=" ++ stamps(entries))
def column_sized(~S:Data,result:Array<Maybe<&1,O.Payload>> & U32,+entries:List<&2,L.Entry>) -> Col.Column<S,O.Payload> & String:
  (values,+size)=result
  column_done(~S,O.observe_column(~S,U32.to_nat(size),Col.Column{values,entries},1),size,entries)
def column(~S:Data,value:Col.Column<S,O.Payload>) -> Col.Column<S,O.Payload> & String:
  match value:
    case Col.Column{values,+entries}:column_sized(~S,Array.size(Maybe<&1,O.Payload>,values),entries)
    case other:(other,"|columnVariant=UNEXPECTED_NON_COLUMN")
def store_done(~S:Data,result:Col.Column<S,O.Payload> & String,+g:G.Graph<S>) -> A.Store<S,O.Components<S>> & String:
  (c,text)=result
  (A.Store{O.Components{c},g},text ++ graph(~S,g))
def store(~S:Data,value:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>> & String:
  match value:
    case A.Store{O.Components{c},+g}:store_done(~S,column(~S,c),g)
def strings(values:List<&2,String>) -> String:
  match values:
    case []:""
    case value <> rest:value ++ "," ++ strings(rest)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ strings(access) ++ ";"
def registrations(values:List<&2,W.RegistrationMeta>) -> String:
  match values:
    case []:""
    case value <> rest:registration(value) ++ registrations(rest)
def live_prefix(result:Array<Bool> & String,value:Bool) -> Array<Bool> & String:
  (live,text)=result
  (live,Bool.show(value) ++ "," ++ text)
def live_next(result:Array<Bool> & Bool,next:Array<Bool> -> Array<Bool> & String) -> Array<Bool> & String:
  (live,value)=result
  live_prefix(next(live),value)
def live_scan(n:Nat,live:Array<Bool>,+index:U32) -> Array<Bool> & String:
  match n:
    case 0n:(live,"")
    case 1n+rest:live_next(Array.get(Bool,live,index),arr => live_scan(rest,arr,(index + 1 : U32)))
def live_done(result:Array<Bool> & String,+size:U32) -> Array<Bool> & String:
  (live,text)=result
  (live,"|liveSize=" ++ U32.show(size) ++ "|liveBits=" ++ text)
def live_sized(result:Array<Bool> & U32) -> Array<Bool> & String:
  (live,+size)=result
  live_done(live_scan(U32.to_nat(size),live,0),size)
def live(live:Array<Bool>) -> Array<Bool> & String:
  live_sized(Array.size(Bool,live))
def combined(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,prior)=result
  (world,prior ++ text)
def world_live(~S:Data,result:Array<Bool> & String,namespace:U32,next:U32,high:U32,capacity:U32,depth:Nat,store:A.Store<S,O.Components<S>>,resource:U32,events:List<&2,A.Notice<S,U32>>,pending:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,+rs:List<&2,W.RegistrationMeta>,nextSys:U32,clock:U32,storeText:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (live,text)=result
  combined(~S,O.observe_complete(~S,W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,rs,nextSys,clock}),storeText ++ text ++ "|registrations=" ++ registrations(rs))
def world_store(~S:Data,result:A.Store<S,O.Components<S>> & String,namespace:U32,next:U32,high:U32,liveArray:Array<Bool>,capacity:U32,depth:Nat,resource:U32,events:List<&2,A.Notice<S,U32>>,pending:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,rs:List<&2,W.RegistrationMeta>,nextSys:U32,clock:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (store,text)=result
  world_live(~S,live(liveArray),namespace,next,high,capacity,depth,store,resource,events,pending,rs,nextSys,clock,text)
def observe(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,components,resource,events,pending,rs,nextSys,clock}:world_store(~S,store(~S,components),namespace,next,high,live,capacity,depth,resource,events,pending,rs,nextSys,clock)
