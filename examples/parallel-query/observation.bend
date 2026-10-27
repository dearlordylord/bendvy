import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/lifecycle.bend as L
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-lifecycle-notices.bend as Notice

def optional(value:Maybe<&2,String>) -> String:
  match value:
    case None{}: "-"
    case Some{value}: value
def tick(value:Tick.Tick) -> String:
  match value:
    case Tick.Tick{epoch,low}: Nat.show(epoch) ++ ":" ++ U32.show(low)
def maybe_tick(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}: "-"
    case Some{value}: tick(value)
def stamp(value:Maybe<&2,L.Stamp>) -> String:
  match value:
    case None{}: "outside"
    case Some{L.Stamp{added,changed}}: maybe_tick(added) ++ "/" ++ maybe_tick(changed)
def slot_stamp(~S:Data,~T:Type,prefix:String,result:Col.Column<S,T> & Maybe<&2,L.Stamp>) -> Col.Column<S,T> & String:
  match result:
    case (column,value): (column,prefix ++ "@" ++ stamp(value) ++ ";")
def slot_value(~S:Data,~T:Type,+index:U32,prefix:String,result:Col.Column<S,T> & Maybe<&2,String>) -> Col.Column<S,T> & String:
  match result:
    case (column,value): slot_stamp(~S,~T,prefix ++ U32.show(index) ++ "=" ++ optional(value),Col.lifecycle(~S,~T,column,index))
def slots(~S:Data,~T:Type,~project:T -> T & String,fuel:Nat,+index:U32,result:Col.Column<S,T> & String) -> Col.Column<S,T> & String:
  match fuel result:
    case 0n result: result
    case 1n+rest Tuple{column,prefix}: slots(~S,~T,~project,rest,U32.add(index,1),slot_value(~S,~T,index,prefix,Col.view(~S,~T,~String,~project,column,index)))
def column_result(~S:Data,~T:Type,result:Col.Column<S,T> & String) -> String:
  match result:
    case (_,text): text
def column_sized(~S:Data,~T:Type,~project:T -> T & String,result:Col.Column<S,T> & U32) -> String:
  match result:
    case (column,+size): "capacity=" ++ U32.show(size) ++ "[" ++ column_result(~S,~T,slots(~S,~T,~project,U32.to_nat(size),0,(column,""))) ++ "]"
def column(~S:Data,~T:Type,~project:T -> T & String,value:Col.Column<S,T>) -> String:
  column_sized(~S,~T,~project,Col.capacity(~S,~T,value))
def cached_result(~T:Type,+cache:U32,result:T & String) -> Layout.Viewed<T,U32> & String:
  match result:
    case (owner,text):(Layout.Viewed{owner,cache},text ++ "@" ++ U32.show(cache))
def cached(~T:Type,~project:T -> T & String,value:Layout.Viewed<T,U32>) -> Layout.Viewed<T,U32> & String:
  match value:
    case Layout.Viewed{owner,cache}:cached_result(~T,cache,project(owner))
def store(~S:Data,value:D.Store(~S)) -> String:
  match value:
    case Product.Owner{Product.Owner{Layout.ColumnSlot{input},Layout.ColumnSlot{output}},_}: "input=" ++ column(~S,~Layout.Viewed<P.Input,U32>,~cached(~P.Input,~P.input),input) ++ ";output=" ++ column(~S,~Layout.Viewed<P.Output,U32>,~cached(~P.Output,~P.output),output)
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
def resource_result(result:Array<U32> & U32) -> String:
  match result:
    case (_,token): U32.show(token)
def resource(~S:Data,value:D.Resources(~S)) -> String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{P.Resource{token},Unit{}},lifecycle}: resource_result(Array.get(U32,token,0)) ++ "@Unit@" ++ stamp(Some{lifecycle})
def notice_selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}: "removed(" ++ key ++ ")"
    case Notice.Despawned{}: "despawned"
def notice_identity(~S:Data,value:Notice.Identity<S>) -> String:
  match value:
    case Notice.Identity{namespace,entity}: U32.show(namespace) ++ ":" ++ key(entity)
def notice_row(~S:Data,value:Notice.Row<S>) -> String:
  match value:
    case Notice.Row{sequence,entity,at}: "sequence=" ++ Nat.show(sequence) ++ ",entity=" ++ notice_identity(~S,entity) ++ ",tick=" ++ tick(at)
def notice_channel(~S:Data,value:Notice.Channel<S>) -> String:
  match value:
    case Notice.Channel{selector,next,previous,current,droppedThrough}: "selector=" ++ notice_selector(selector) ++ ",next=" ++ Nat.show(next) ++ ",previous=" ++ List.show(&2,Notice.Row<S>,notice_row(~S),previous) ++ ",current=" ++ List.show(&2,Notice.Row<S>,notice_row(~S),current) ++ ",droppedThrough=" ++ Nat.show(droppedThrough)
def notice_active(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,selector}: "id=" ++ U32.show(id) ++ ",selector=" ++ notice_selector(selector)
def journal(~S:Data,value:Notice.Journal<S>) -> String:
  match value:
    case Notice.Journal{namespace,channels,nextReader,active}: "namespace=" ++ U32.show(namespace) ++ ",channels=" ++ List.show(&2,Notice.Channel<S>,notice_channel(~S),channels) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",active=" ++ List.show(&2,Notice.Active,notice_active,active)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access)
def clock(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}: tick(now) ++ ":" ++ List.show(&2,Tick.Tick,tick,scopes)
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match value:
    case W.World{namespace,alloc,components,res,events,pending,registrations,nextSystem,worldClock,lifecycle}: "namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ allocator(alloc) ++ "};" ++ store(~S,components) ++ ";resource=" ++ resource(~S,res) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),D.Resources(~S),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystem) ++ ";clock=" ++ clock(worldClock) ++ ";lifecycle={" ++ journal(~S,lifecycle) ++ "}"
def local_result(runs:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,token): U32.show(token) ++ ":" ++ U32.show(runs)
def local(value:Body.Local) -> String:
  match value:
    case Body.Local{token,runs}: local_result(runs,Array.get(U32,token,0))
