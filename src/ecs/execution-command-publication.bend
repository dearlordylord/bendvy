import Base
import ./world.bend as W
import ./entity-allocator.bend as A
import ./entity-key.bend as Key
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./deferred-command.bend as Deferred
import ./execution-composer-layout.bend as Layout
import ./chunk-column.bend as Column
import ./execution-command-buffer.bend as Buffer

# The interpreter owns the complete World. Gameplay supplies only raw affine
# payloads to its hidden queue; schema initialization happens at publication.
type Remainder<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Remainder{namespace:U32,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State}
type Applied<-S:Data,-layout:Layout.Layout,-route:Layout.Route> is Type:
  Applied{allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,receipt:Buffer.Receipt<S,Layout.payload(layout,route)>}
type Drained<-S:Data,-layout:Layout.Layout,-route:Layout.Route> is Type:
  Drained{allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route)>>}
def unwrap(~P:Type,~V:Data,value:Maybe<&1,Layout.Viewed<P,V>>) -> Maybe<&1,P>:
  match value:
    case None{}:None{}
    case Some{Layout.Viewed{owner,_}}:Some{owner}
def swapped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,handle:W.Handle<S>,result:Column.SwapOutcome<S,Layout.stored(layout,route)>) -> Applied<S,layout,route>:
  match result:
    case Column.Accepted{column,previous}:Applied{allocator,column,Buffer.Applied{handle,unwrap(~(Layout.payload(layout,route)),~(Layout.view(layout,route)),previous)}}
    case Column.Rejected{column,incoming}:Applied{allocator,column,Buffer.Refused{handle,unwrap(~(Layout.payload(layout,route)),~(Layout.view(layout,route)),incoming)}}
def insert_bounded(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,incoming:Layout.payload(layout,route),tick:Tick.Tick,allowed:Bool) -> Applied<S,layout,route>:
  match handle allowed:
    case handle False{}:Applied{allocator,column,Buffer.Refused{handle,Some{incoming}}}
    case W.Handle{namespace,+key} True{}:swapped(~S,~layout,~route,allocator,W.Handle{namespace,key},Column.swap_at(~S,~(Layout.stored(layout,route)),Column.ensure(~S,~(Layout.stored(layout,route)),column,U32.add(Key.index(key),1)),Key.index(key),Some{Layout.initialize(layout,route,incoming)},tick))
def remove_present(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,tick:Tick.Tick,present:Bool) -> Applied<S,layout,route>:
  match handle present:
    case handle False{}:Applied{allocator,column,Buffer.Applied{handle,None{}}}
    case W.Handle{namespace,+key} True{}:swapped(~S,~layout,~route,allocator,W.Handle{namespace,key},Column.swap_at(~S,~(Layout.stored(layout,route)),column,Key.index(key),None{},tick))
def remove_bounded(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,+handle:W.Handle<S>,tick:Tick.Tick,result:Column.Column<S,Layout.stored(layout,route)> & U32) -> Applied<S,layout,route>:
  match handle result:
    case W.Handle{+namespace,+key}, (column,capacity):remove_present(~S,~layout,~route,allocator,column,W.Handle{namespace,key},tick,U32.is_lt(Key.index(key),capacity))
def prepared(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick) -> Applied<S,layout,route>:
  match handle incoming:
    case handle None{}:remove_bounded(~S,~layout,~route,allocator,handle,tick,Column.capacity(~S,~(Layout.stored(layout,route)),column))
    case W.Handle{+namespace,+key} Some{owner}:insert_bounded(~S,~layout,~route,allocator,column,W.Handle{namespace,key},owner,tick,U32.is_lt(Key.index(key),131072))
def admitted(~S:Data,~layout:Layout.Layout,~route:Layout.Route,column:Column.Column<S,Layout.stored(layout,route)>,handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick,result:A.Allocator & Bool) -> Applied<S,layout,route>:
  match result:
    case (allocator,False{}):Applied{allocator,column,Buffer.Refused{handle,incoming}}
    case (allocator,True{}):prepared(~S,~layout,~route,allocator,column,handle,incoming,tick)
def namespaced(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick,allowed:Bool) -> Applied<S,layout,route>:
  match handle allowed:
    case handle False{}:Applied{allocator,column,Buffer.Refused{handle,incoming}}
    case W.Handle{+namespace,+key} True{}:admitted(~S,~layout,~route,column,W.Handle{namespace,key},incoming,tick,A.checked(allocator,key,1))
def apply(~S:Data,~layout:Layout.Layout,~route:Layout.Route,namespace:U32,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,entry:Buffer.Entry<S,Layout.payload(layout,route)>,tick:Tick.Tick) -> Applied<S,layout,route>:
  match entry:
    case Buffer.Entry{W.Handle{+ownerNamespace,key},incoming}:namespaced(~S,~layout,~route,allocator,column,W.Handle{ownerNamespace,key},incoming,tick,U32.is_eq(namespace,ownerNamespace))
def recorded(~S:Data,~layout:Layout.Layout,~route:Layout.Route,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route)>>,result:Applied<S,layout,route>) -> Drained<S,layout,route>:
  match result:
    case Applied{allocator,column,receipt}:Drained{allocator,column,receipt <> receipts}
def next(~S:Data,~layout:Layout.Layout,~route:Layout.Route,namespace:U32,entry:Buffer.Entry<S,Layout.payload(layout,route)>,tick:Tick.Tick,result:Drained<S,layout,route>) -> Drained<S,layout,route>:
  match result:
    case Drained{allocator,column,receipts}:recorded(~S,~layout,~route,receipts,apply(~S,~layout,~route,namespace,allocator,column,entry,tick))
def drain(~S:Data,~layout:Layout.Layout,~route:Layout.Route,+namespace:U32,entries:List<Buffer.Entry<S,Layout.payload(layout,route)>>,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+tick:Tick.Tick,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route)>>) -> Drained<S,layout,route>:
  match entries:
    case []:Drained{allocator,column,receipts}
    case entry <> rest:next(~S,~layout,~route,namespace,entry,tick,drain(~S,~layout,~route,namespace,rest,allocator,column,tick,receipts))
def restored(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,rest:Layout.column_rest(~S,layout,route),remainder:Remainder<S,Layout.columns(~S,layout),R,E>,result:Drained<S,layout,route>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Buffer<S,Layout.payload(layout,route)>:
  match remainder result:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock} Drained{allocator,column,receipts}:(W.World{namespace,allocator,Layout.column_put(~S,layout,route,rest,Layout.ColumnSlot{column}),resource,events,pending,registrations,nextSystemId,clock},Buffer.Buffer{[],receipts})
def selected(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,remainder:Remainder<S,Layout.columns(~S,layout),R,E>,buffer:Buffer.Buffer<S,Layout.payload(layout,route)>,tick:Tick.Tick,result:Layout.column_rest(~S,layout,route) & Layout.ColumnSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Buffer<S,Layout.payload(layout,route)>:
  match remainder buffer result:
    case Remainder{+namespace,resource,events,pending,registrations,nextSystemId,clock} Buffer.Buffer{entries,receipts}, (rest,Layout.ColumnSlot{column}):restored(~S,~R,~E,~layout,~route,rest,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock},drain(~S,~layout,~route,namespace,entries,allocator,column,tick,receipts))

# Internal boundary operation. The caller captures one publication tick after
# joining scopes; all command owners at that boundary use the same tick.
# Bevy ad678262 schedule/executor/single_threaded.rs apply_deferred publishes
# queued mutations after a barrier, including commands from handled errors.
# This Bend interpreter also returns displaced/refused actual Type owners.
def apply_at(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},world:W.World<S,Layout.columns(~S,layout),R,E>,buffer:Buffer.Buffer<S,Layout.payload(layout,route)>,tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Buffer<S,Layout.payload(layout,route)>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:selected(~S,~R,~E,~layout,~route,allocator,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock},buffer,tick,Layout.column_take(~S,layout,route,store))
