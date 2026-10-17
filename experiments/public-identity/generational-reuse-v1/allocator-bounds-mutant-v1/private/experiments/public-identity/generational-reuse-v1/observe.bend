import Base
import fixture.bend as F
import owner-observer.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/entity-key.bend as K
import ../../../src/ecs/entity-allocator.bend as A
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/transaction.bend as T

def phase(value:A.Phase) -> String:
  match value:
    case A.Consumed{}:"Consumed"
    case A.Pending{}:"Pending"
    case A.Live{}:"Live"
    case A.DeadRetained{}:"DeadRetained"
    case A.Free{}:"Free"
def slot(value:A.Slot) -> A.Slot & String:
  match value:
    case A.Slot{+generation,+value}:(A.Slot{generation,value},U32.show(generation) ++ ":" ++ phase(value))
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<A.Slot> & String) -> A.Allocator & String:
  match observed:
    case (slots,text):(A.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,K.Key,F.key_text,order))
def allocator(value:A.Allocator) -> A.Allocator & String:
  match value:
    case A.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,D.array(~A.Slot,~slot,slots))
def arrays_join(head:Array<U32> & String,tail:List<Array<U32>> & String) -> List<Array<U32>> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def arrays(values:List<Array<U32>>) -> List<Array<U32>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:arrays_join(D.u32_array(head),arrays(tail))
def store_join(~S:Data,+trace:List<&2,String>,column:Col.Column<S,Array<U32>> & String,returned:List<Array<U32>> & String) -> F.Store<S> & String:
  (column,ct)=column
  (returned,rt)=returned
  (F.Store{column,returned,trace},"column=" ++ ct ++ ";returned=" ++ rt ++ ";trace=" ++ List.show(&2,String,x=>x,trace))
def store(~S:Data,value:F.Store<S>) -> F.Store<S> & String:
  match value:
    case F.Store{column,returned,trace}:store_join(~S,trace,D.column(~S,~Array<U32>,~D.u32_array,column),arrays(returned))
def notice(~S:Data,value:F.Notice<S>) -> String:
  match value:
    case F.Removed{handle}:"Removed(" ++ F.handle_text(~S,handle) ++ ")"
    case F.Cleared{handle}:"Cleared(" ++ F.handle_text(~S,handle) ++ ")"
def world_join(~S:Data,+ns:U32,+events:List<&2,F.Notice<S>>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,allocator:A.Allocator & String,store:F.Store<S> & String,resource:Array<U32> & String,pending:List<(F.World(~S) -> F.World(~S))> & Nat) -> F.World(~S) & String:
  (allocator,at)=allocator
  (store,st)=store
  (resource,rt)=resource
  (pending,pt)=pending
  (W.World{ns,allocator,store,resource,events,pending,regs,sid,clock},"ns=" ++ U32.show(ns) ++ ";allocator={" ++ at ++ "};store={" ++ st ++ "};resource=" ++ rt ++ ";events=" ++ List.show(&2,F.Notice<S>,notice(~S),events) ++ ";pending=" ++ Nat.show(pt) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,D.registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock))
def world_raw(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,owner,components,resource,events,pending,regs,sid,clock}:world_join(~S,ns,events,regs,sid,clock,allocator(owner),store(~S,components),D.u32_array(resource),D.callbacks(~F.World(~S),~F.World(~S),pending))
def world_handles(~S:Data,observed:F.World(~S) & List<&2,W.Handle<S>>) -> F.World(~S) & String:
  match observed:
    case (world,handles):(world,List.show(&2,W.Handle<S>,F.handle_text(~S),handles))
def world_joined(~S:Data,before:String,observed:F.World(~S) & String) -> F.World(~S) & String:
  match observed:
    case (world,handles):(world,before ++ ";queryOrder=" ++ handles)
def world_visible(~S:Data,observed:F.World(~S) & String) -> F.World(~S) & String:
  match observed:
    case (world,text):world_joined(~S,text,world_handles(~S,W.handles(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world)))
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  world_visible(~S,world_raw(~S,value))
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{value}:"Rejected(" ++ error(value) ++ ")"
def tx_join(~S:Data,world:F.World(~S) & String,undo:List<(F.World(~S) -> F.World(~S))> & Nat,commands:List<(F.World(~S) -> F.World(~S))> & Nat,+events:List<&2,F.Notice<S>>) -> F.Tx(~S) & String:
  (world,wt)=world
  (undo,ut)=undo
  (commands,ct)=commands
  (T.Tx{world,undo,commands,events},"world={" ++ wt ++ "};undo=" ++ Nat.show(ut) ++ ";commands=" ++ Nat.show(ct) ++ ";events=" ++ List.show(&2,F.Notice<S>,notice(~S),events))
def tx(~S:Data,value:F.Tx(~S)) -> F.Tx(~S) & String:
  match value:
    case T.Tx{owner,undo,commands,events}:tx_join(~S,world(~S,owner),D.callbacks(~F.World(~S),~F.World(~S),undo),D.callbacks(~F.World(~S),~F.World(~S),commands),events)
