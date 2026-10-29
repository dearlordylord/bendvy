import Base
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Lifecycle
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/world.bend as W

def optional(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"absent"
    case Some{text}:text
def projected(~T:Type,result:T & String) -> String:
  match result:
    case (_,value):value
def stamp_text(value:Maybe<&2,Lifecycle.Stamp>) -> String:
  match value:
    case None{}:"invalid"
    case Some{Lifecycle.Stamp{added,changed}}:Tick.cursor_show(added) ++ "/" ++ Tick.cursor_show(changed)
type Walk<-S:Data,-P:Type> is Type:
  Walk{column:Col.Column<S,P>,index:U32,text:String}
def stamp_done(~S:Data,~P:Type,+index:U32,text:String,value:String,result:Col.Column<S,P> & Maybe<&2,Lifecycle.Stamp>) -> Walk<S,P>:
  match result:
    case (column,stamp):Walk{column,U32.add(index,1),text ++ U32.show(index) ++ "=" ++ value ++ "@" ++ stamp_text(stamp) ++ ";"}
def view_done(~S:Data,~P:Type,+index:U32,text:String,result:Col.Column<S,P> & Maybe<&2,String>) -> Walk<S,P>:
  match result:
    case (column,value):stamp_done(~S,~P,index,text,optional(value),Col.lifecycle(~S,~P,column,index))
def step(~S:Data,~P:Type,~project:P -> P & String,state:Walk<S,P>) -> Walk<S,P>:
  match state:
    case Walk{column,+index,text}:view_done(~S,~P,index,text,Col.view(~S,~P,~String,~project,column,index))
def walk(~S:Data,~P:Type,~project:P -> P & String,fuel:Nat,state:Walk<S,P>) -> String:
  match fuel state:
    case 0n Walk{_,_,text}:text
    case 1n++rest state:walk(~S,~P,~project,rest,step(~S,~P,~project,state))
def capacity_done(~S:Data,~P:Type,~project:P -> P & String,result:Col.Column<S,P> & U32) -> String:
  match result:
    case (column,+capacity):"capacity=" ++ U32.show(capacity) ++ "[" ++ walk(~S,~P,~project,U32.to_nat(capacity),Walk{column,0,""}) ++ "]"
def phase(value:Allocator.Phase) -> String:
  match value:
    case Allocator.Consumed{}: "consumed"
    case Allocator.Pending{}: "pending"
    case Allocator.Live{}: "live"
    case Allocator.DeadRetained{}: "dead"
    case Allocator.Free{}: "free"
def allocator_slot(value:Allocator.Slot) -> String:
  match value:
    case Allocator.Slot{generation,value}: U32.show(generation) ++ ":" ++ phase(value)
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}: U32.show(index) ++ ":" ++ U32.show(generation)
def allocator(value:Allocator.Allocator) -> String:
  match value:
    case Allocator.Allocator{next,high,slots,capacity,depth,free,order}: "next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",slots=" ++ List.show(&1,Allocator.Slot,allocator_slot,Array.to_list(~Allocator.Slot,slots)) ++ ",free=" ++ List.show(&2,U32,U32.show,free) ++ ",order=" ++ List.show(&2,Key.Key,key,order)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access)
def clock(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}: Tick.show(now) ++ ":" ++ List.show(&2,Tick.Tick,Tick.show,scopes)
