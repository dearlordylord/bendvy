import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-permission.bend as Permission
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-publication.bend as Publication
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../test-fixtures/common/column-observation.bend as Observe

type Schema is Data:Schema{}
def bumped(result:Array<U32> & U32) -> P.Token & U32:
  match result:
    case (owner,+value):(P.Token{Array.set(U32,owner,0,U32.add(value,1))},U32.add(value,1))
def refresh(owner:P.Token) -> P.Token & U32:
  match owner:
    case P.Token{owner}:bumped(Array.get(U32,owner,0))
def layout() -> Layout.Layout:Layout.LayoutLeaf{P.Token,U32,refresh,"token",Policy.Ordinary{}}
def Store() -> Type:Layout.columns(~Schema,layout())
def value(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def token(owner:P.Token) -> String:
  match owner:
    case P.Token{owner}:value(Array.get(U32,owner,0))
def maybe(owner:Maybe<&1,P.Token>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:token(owner)
def handle(value:W.Handle<Schema>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
def receipt(value:Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Applied{owner,previous}:"applied:" ++ handle(owner) ++ ":" ++ maybe(previous)
    case Buffer.Refused{owner,incoming}:"refused:" ++ handle(owner) ++ ":" ++ maybe(incoming)
    case Buffer.Despawned{owner,removed}:"despawned:" ++ handle(owner) ++ ":" ++ maybe(removed)
    case Buffer.DespawnRefused{owner}:"despawn-refused:" ++ handle(owner)
def projected(+cached:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (values,+raw):(Layout.Viewed{P.Token{values},cached},U32.show(raw) ++ "/cache=" ++ U32.show(cached))
def project(owner:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match owner:
    case Layout.Viewed{P.Token{values},+cached}:projected(cached,Array.get(U32,values,0))
def at(index:U32,text:String,column:Column.Column<Schema,Layout.Viewed<P.Token,U32>>) -> Observe.Walk<Schema,Layout.Viewed<P.Token,U32>>:
  Observe.step(~Schema,~(Layout.Viewed<P.Token,U32>),~project,Observe.Walk{column,index,text})
def last(result:Observe.Walk<Schema,Layout.Viewed<P.Token,U32>>) -> String:
  match result:
    case Observe.Walk{_,_,text}:text
def boundary(result:Observe.Walk<Schema,Layout.Viewed<P.Token,U32>>) -> String:
  match result:
    case Observe.Walk{column,_,text}:last(at(Column.maximum_capacity(),text,column))
def first(result:Observe.Walk<Schema,Layout.Viewed<P.Token,U32>>) -> String:
  match result:
    case Observe.Walk{column,_,text}:boundary(at(U32.sub(Column.maximum_capacity(),1),text,column))
def before_last(result:Observe.Walk<Schema,Layout.Viewed<P.Token,U32>>) -> String:
  match result:
    case Observe.Walk{column,_,text}:first(at(U32.sub(Column.maximum_capacity(),2),text,column))
def column(result:Column.Column<Schema,Layout.Viewed<P.Token,U32>> & U32) -> String:
  match result:
    case (column,capacity):"capacity=" ++ U32.show(capacity) ++ "[" ++ before_last(at(0,"",column)) ++ "]"
def observed(prefix:String,result:W.World<Schema,Store(),Unit,Unit> & Buffer.Buffer<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match result:
    case (W.World{namespace,Allocator.Allocator{next,high,_,capacity,depth,free,order},Layout.ColumnSlot{store},_,events,pending,registrations,nextSystem,clock,lifecycle},Buffer.Buffer{queue,receipts}):prefix ++ "|namespace=" ++ U32.show(namespace) ++ ";allocator=" ++ U32.show(next) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,Key.Key,Observe.key,order) ++ "|" ++ column(Column.capacity(~Schema,~(Layout.Viewed<P.Token,U32>),store)) ++ "|events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Unit,Unit>>,pending)) ++ ";registrations=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations)) ++ ";next=" ++ U32.show(nextSystem) ++ ";clock=" ++ Observe.clock(clock) ++ "|queued=" ++ Nat.show(List.length(&1,Buffer.Entry<Schema,P.Token>,queue)) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts)
# This boundary control provisions sparse live allocator slots directly. It does
# not claim reserve/spawn success at either index. Publication still checks both
# actual generation-bearing live slots before the component capacity preflight.
def initial_done(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def initial() -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  initial_done(Column.swap(~Schema,~(Layout.Viewed<P.Token,U32>),Column.empty(~Schema,~(Layout.Viewed<P.Token,U32>)),0,Some{Layout.Viewed{P.Token{ALeaf{1}},1}}))
def ready(allocator:Allocator.Allocator,low:Bool,high:Bool) -> String:
  +a:W.Handle<Schema> = W.Handle{1,Key.EntityKey{U32.sub(Column.maximum_capacity(),1),0}}
  +b:W.Handle<Schema> = W.Handle{1,Key.EntityKey{Column.maximum_capacity(),0}}
  observed("live=" ++ Bool.pick(String,low,"true","false") ++ ":" ++ Bool.pick(String,high,"true","false"),Publication.apply_at(~Schema,~Unit,~Unit,~layout(),~(Layout.AtLeaf{}),~{==},Permission.FamilyOnly{},W.World{1,allocator,Layout.ColumnSlot{initial()},Unit{},[],[],[],1,Clock.empty(),Notice.empty(~Schema,1)},Buffer.insert(~Schema,~P.Token,~(Removed.Removed(layout())),Buffer.insert(~Schema,~P.Token,~(Removed.Removed(layout())),Buffer.empty(~Schema,~P.Token,~(Removed.Removed(layout()))),a,P.Token{ALeaf{71}}),b,P.Token{ALeaf{81}}),Tick.Tick{0n,9}))
def checked_high(low:Bool,result:Allocator.Allocator & Bool) -> String:
  match result:
    case (allocator,high):ready(allocator,low,high)
def checked_low(result:Allocator.Allocator & Bool) -> String:
  match result:
    case (allocator,low):checked_high(low,Allocator.checked(allocator,Key.EntityKey{Column.maximum_capacity(),0},1))
def initialized(slots:Array<Allocator.Slot>) -> String:
  checked_low(Allocator.checked(Allocator.Allocator{U32.add(Column.maximum_capacity(),1),Column.maximum_capacity(),slots,U32.mul(Column.maximum_capacity(),2),1n+U32.log2(Column.maximum_capacity()),[],[Key.EntityKey{U32.sub(Column.maximum_capacity(),1),0},Key.EntityKey{Column.maximum_capacity(),0}]},Key.EntityKey{U32.sub(Column.maximum_capacity(),1),0},1))
def main() -> IO(Unit):
  IO.print(initialized(Array.set(Allocator.Slot,Array.set(Allocator.Slot,Array.new(Allocator.Slot,1n+U32.log2(Column.maximum_capacity()),Allocator.Slot{0,Allocator.Consumed{}}),U32.sub(Column.maximum_capacity(),1),Allocator.Slot{0,Allocator.Live{}}),Column.maximum_capacity(),Allocator.Slot{0,Allocator.Live{}})))
