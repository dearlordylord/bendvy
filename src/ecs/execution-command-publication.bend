import Base
import ./execution-query-identity.bend as Index
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./entity-allocator.bend as A
import ./entity-key.bend as Key
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./deferred-command.bend as Deferred
import ./execution-composer-layout.bend as Layout
import ./chunk-column.bend as Column
import ./execution-command-buffer.bend as Buffer
import ./execution-command-removed.bend as Removed
import ./execution-command-permission.bend as Permission
import ./execution-reservation-materialization.bend as Spawn
import ./execution-reservation-bundle.bend as Bundle
import ./execution-relation-buffer.bend as Relation
import ./execution-relation-context.bend as Context

# The interpreter owns the complete World. Gameplay supplies only raw affine
# payloads to its hidden queue; schema initialization happens at publication.
type Remainder<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Remainder{namespace:U32,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
type Applied<-S:Data,-layout:Layout.Layout,-route:Layout.Route> is Type:
  Applied{allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,receipt:Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>,removed:Bool}
def handle_namespace(~S:Data,handle:W.Handle<S>) -> U32:
  match handle:
    case W.Handle{namespace,_}:namespace
def unwrap(~P:Type,~V:Data,value:Maybe<&1,Layout.Viewed<P,V>>) -> Maybe<&1,P>:
  match value:
    case None{}:None{}
    case Some{Layout.Viewed{owner,_}}:Some{owner}
def identity(~S:Data,handle:W.Handle<S>) -> Notice.Identity<S>:
  match handle:
    case W.Handle{namespace,key}:Notice.Identity{namespace,key}
def removed_notice(~S:Data,selector:Notice.Selector,entity:Notice.Identity<S>,tick:Tick.Tick,journal:Notice.Journal<S>,removed:Bool) -> Notice.Journal<S>:
  match removed:
    case False{}:journal
    case True{}:Notice.append(~S,selector,entity,tick,journal)
def swapped_previous(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,handle:W.Handle<S>,removing:Bool,previous:Maybe<&1,Layout.payload(layout,route)>) -> Applied<S,layout,route>:
  match previous:
    case None{}:Applied{allocator,column,Buffer.Applied{handle,None{}},False{}}
    case Some{owner}:Applied{allocator,column,Buffer.Applied{handle,Some{owner}},removing}
def swapped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,handle:W.Handle<S>,result:Column.SwapOutcome<S,Layout.stored(layout,route)>,removing:Bool) -> Applied<S,layout,route>:
  match result:
    case Column.Accepted{column,previous}:swapped_previous(~S,~layout,~route,allocator,column,handle,removing,unwrap(~(Layout.payload(layout,route)),~(Layout.view(layout,route)),previous))
    case Column.Rejected{column,incoming}:Applied{allocator,column,Buffer.Refused{handle,unwrap(~(Layout.payload(layout,route)),~(Layout.view(layout,route)),incoming)},False{}}
def insert_offset(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,incoming:Layout.payload(layout,route),tick:Tick.Tick,offset:Maybe<&2,U32>) -> Applied<S,layout,route>:
  match offset:
    case None{}:Applied{allocator,column,Buffer.Refused{handle,Some{incoming}},False{}}
    case Some{+offset}:swapped(~S,~layout,~route,allocator,handle,Column.swap_at(~S,~(Layout.stored(layout,route)),Column.ensure(~S,~(Layout.stored(layout,route)),column,U32.add(offset,1)),offset,Some{Layout.initialize(layout,route,incoming)},tick),False{})
def insert_bounded(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,incoming:Layout.payload(layout,route),tick:Tick.Tick,allowed:Bool) -> Applied<S,layout,route>:
  match handle allowed:
    case handle False{}:Applied{allocator,column,Buffer.Refused{handle,Some{incoming}},False{}}
    case +handle True{}:insert_offset(~S,~layout,~route,allocator,column,handle,incoming,tick,Index.physical_index(W.handle_index(~S,handle)))
def remove_offset(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,tick:Tick.Tick,offset:Maybe<&2,U32>) -> Applied<S,layout,route>:
  match offset:
    case None{}:Applied{allocator,column,Buffer.Refused{handle,None{}},False{}}
    case Some{offset}:swapped(~S,~layout,~route,allocator,handle,Column.swap_at(~S,~(Layout.stored(layout,route)),column,offset,None{},tick),True{})
def remove_present(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,tick:Tick.Tick,present:Bool) -> Applied<S,layout,route>:
  match handle present:
    case handle False{}:Applied{allocator,column,Buffer.Applied{handle,None{}},False{}}
    case +handle True{}:remove_offset(~S,~layout,~route,allocator,column,handle,tick,Index.physical_index(W.handle_index(~S,handle)))
def remove_bounded(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,+handle:W.Handle<S>,tick:Tick.Tick,result:Column.Column<S,Layout.stored(layout,route)> & U32) -> Applied<S,layout,route>:
  match handle result:
    case W.Handle{+namespace,+key}, (column,capacity):remove_present(~S,~layout,~route,allocator,column,W.Handle{namespace,key},tick,U32.is_le(Key.index(key),capacity))
def prepared(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,+handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick) -> Applied<S,layout,route>:
  match handle incoming:
    case handle None{}:remove_bounded(~S,~layout,~route,allocator,handle,tick,Column.capacity(~S,~(Layout.stored(layout,route)),column))
    case W.Handle{+namespace,+key} Some{owner}:insert_bounded(~S,~layout,~route,allocator,column,W.Handle{namespace,key},owner,tick,U32.is_le(Key.index(key),Column.maximum_capacity()))
def admitted(~S:Data,~layout:Layout.Layout,~route:Layout.Route,column:Column.Column<S,Layout.stored(layout,route)>,handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick,result:A.Allocator & Bool) -> Applied<S,layout,route>:
  match result:
    case (allocator,False{}):Applied{allocator,column,Buffer.Refused{handle,incoming},False{}}
    case (allocator,True{}):prepared(~S,~layout,~route,allocator,column,handle,incoming,tick)
def namespaced(~S:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,column:Column.Column<S,Layout.stored(layout,route)>,handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick,allowed:Bool) -> Applied<S,layout,route>:
  match handle allowed:
    case handle False{}:Applied{allocator,column,Buffer.Refused{handle,incoming},False{}}
    case W.Handle{+namespace,+key} True{}:admitted(~S,~layout,~route,column,W.Handle{namespace,key},incoming,tick,A.checked(allocator,key,1))
def family_restored(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,rest:Layout.column_rest(~S,layout,route),remainder:Remainder<S,Layout.columns(~S,layout),R,E>,result:Applied<S,layout,route>,tick:Tick.Tick,handle:W.Handle<S>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match remainder result:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle} Applied{allocator,column,receipt,removed}:(W.World{namespace,allocator,Layout.column_put(~S,layout,route,rest,Layout.ColumnSlot{column}),resource,events,pending,registrations,nextSystemId,clock,removed_notice(~S,Notice.Removed{Layout.key(layout,route)},identity(~S,handle),tick,lifecycle,removed)},receipt)
def family_selected(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,remainder:Remainder<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,+tick:Tick.Tick,result:Layout.column_rest(~S,layout,route) & Layout.ColumnSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match remainder result:
    case Remainder{+namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle}, (rest,Layout.ColumnSlot{column}):family_restored(~S,~R,~E,~layout,~route,rest,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle},namespaced(~S,~layout,~route,allocator,column,handle,incoming,tick,U32.is_eq(namespace,handle_namespace(~S,handle))),tick,handle)
def family(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,world:W.World<S,Layout.columns(~S,layout),R,E>,handle:W.Handle<S>,incoming:Maybe<&1,Layout.payload(layout,route)>,tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:family_selected(~S,~R,~E,~layout,~route,allocator,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle},handle,incoming,tick,Layout.column_take(~S,layout,route,store))
# Bevy ad678262 system/commands/mod.rs EntityCommands::despawn queues a handled
# entity command; world/mod.rs despawn_with_caller refuses a missing entity and
# despawn removes all components before freeing its index. This boundary also
# returns each actual affine payload instead of dropping it.
def despawn_noticed(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,namespace:U32,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,Layout.columns(~S,layout),R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,allocator:A.Allocator,store:Layout.columns(~S,layout),+handle:W.Handle<S>,tick:Tick.Tick,result:Notice.Journal<S> & Removed.Removed(layout)) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match result:
    case (journal,removed):(W.World{namespace,A.release(A.write_phase(allocator,W.handle_key(~S,handle),A.DeadRetained{}),W.handle_key(~S,handle)),store,resource,events,pending,registrations,nextSystemId,clock,Notice.append(~S,Notice.Despawned{},identity(~S,handle),tick,journal)},Buffer.Despawned{handle,removed})
def despawn_removed(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,allocator:A.Allocator,remainder:Remainder<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,result:Layout.columns(~S,layout) & Removed.Removed(layout),+tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match remainder result:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle}, (store,removed):despawn_noticed(~S,~R,~E,~layout,~route,namespace,resource,events,pending,registrations,nextSystemId,clock,allocator,store,handle,tick,Removed.notices(~S,layout)(identity(~S,handle),tick,lifecycle,removed))
def despawn_offset(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,store:Layout.columns(~S,layout),remainder:Remainder<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,allocator:A.Allocator,+tick:Tick.Tick,offset:Maybe<&2,U32>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match remainder offset:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle} None{}:(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},Buffer.DespawnRefused{handle})
    case remainder Some{offset}:despawn_removed(~S,~R,~E,~layout,~route,allocator,remainder,handle,Removed.take(~S,layout)(offset,store),tick)
def despawn_live(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,store:Layout.columns(~S,layout),remainder:Remainder<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,result:A.Allocator & Bool,+tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match remainder result:
    case Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle}, (allocator,False{}):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},Buffer.DespawnRefused{handle})
    case remainder, (allocator,True{}):despawn_offset(~S,~R,~E,~layout,~route,store,remainder,handle,allocator,tick,Index.physical_index(W.handle_index(~S,handle)))
def despawn_allowed(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,world:W.World<S,Layout.columns(~S,layout),R,E>,+handle:W.Handle<S>,allowed:Bool,+tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match world allowed:
    case world False{}:(world,Buffer.DespawnRefused{handle})
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle} True{}:despawn_live(~S,~R,~E,~layout,~route,store,Remainder{namespace,resource,events,pending,registrations,nextSystemId,clock,lifecycle},handle,A.checked(allocator,W.handle_key(~S,handle),1),tick)
def despawn_namespace(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,+handle:W.Handle<S>,permission:Permission.Permission,result:W.World<S,Layout.columns(~S,layout),R,E> & U32,+tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match result:
    case (world,namespace):despawn_allowed(~S,~R,~E,~layout,~route,world,handle,Bool.and(Permission.agrees(permission,Permission.EntityStructural{}),U32.is_eq(namespace,handle_namespace(~S,handle))),tick)
def spawn_returned(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,result:Bundle.Publication<S,Layout.columns(~S,layout),R,E,layout>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match result:
    case Bundle.Materialized{world,handle,previous}:(world,Buffer.Spawned{handle,previous})
    case Bundle.RefusedPublication{world,handle,bundle,reason}:(world,Buffer.SpawnRefused{handle,bundle,reason})
def entry(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~resources:Layout.Layout,~sameWR:{R == Layout.resources(~S,resources) : Type},~grants:Permission.Relations<S,resources>,+context:Context.Context<S,R,resources,sameWR>,permission:Permission.Permission,world:W.World<S,Layout.columns(~S,layout),R,E>,value:Buffer.Entry<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match value:
    case Buffer.Relation{resourceRoute,operation}:Relation.apply(~S,~Layout.columns(~S,layout),~R,~E,~Layout.payload(layout,route),~Removed.Removed(layout),~resources,~sameWR,~grants,context,resourceRoute,operation,world,tick)
    case Buffer.Entry{handle,incoming}:family(~S,~R,~E,~layout,~route,world,handle,incoming,tick)
    case Buffer.Spawn{handle,bundle}:spawn_returned(~S,~R,~E,~layout,~route,Spawn.apply_at(~S,~R,~E,~layout,permission,world,handle,bundle,tick))
    case Buffer.Despawn{+handle}:despawn_namespace(~S,~R,~E,~layout,~route,handle,permission,W.namespace(~S,~(Layout.columns(~S,layout)),~R,~E,world),tick)
def recorded(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>,result:W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>) -> W.World<S,Layout.columns(~S,layout),R,E> & List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>:
  match result:
    case (world,receipt):(world,receipt <> receipts)
def next(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~resources:Layout.Layout,~sameWR:{R == Layout.resources(~S,resources) : Type},~grants:Permission.Relations<S,resources>,+context:Context.Context<S,R,resources,sameWR>,permission:Permission.Permission,value:Buffer.Entry<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),R,E> & List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>) -> W.World<S,Layout.columns(~S,layout),R,E> & List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>:
  match result:
    case (world,receipts):recorded(~S,~R,~E,~layout,~route,receipts,entry(~S,~R,~E,~layout,~route,~resources,~sameWR,~grants,context,permission,world,value,tick))
def drain(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~resources:Layout.Layout,~sameWR:{R == Layout.resources(~S,resources) : Type},~grants:Permission.Relations<S,resources>,+context:Context.Context<S,R,resources,sameWR>,+permission:Permission.Permission,entries:List<Buffer.Entry<S,Layout.payload(layout,route),Removed.Removed(layout)>>,world:W.World<S,Layout.columns(~S,layout),R,E>,+tick:Tick.Tick,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>) -> W.World<S,Layout.columns(~S,layout),R,E> & List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>:
  match entries:
    case []:(world,receipts)
    case value <> rest:next(~S,~R,~E,~layout,~route,~resources,~sameWR,~grants,context,permission,value,tick,drain(~S,~R,~E,~layout,~route,~resources,~sameWR,~grants,context,permission,rest,world,tick,receipts))
def restored(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,result:W.World<S,Layout.columns(~S,layout),R,E> & List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match result:
    case (world,receipts):(world,Buffer.Buffer{[],receipts})
# Bevy ad678262 single_threaded.rs apply_deferred publishes each system's queued
# mutations after a barrier, including commands from handled body errors. This
# interpreter additionally returns all displaced affine owners in receipts.
def apply_at(~S:Data,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~resources:Layout.Layout,~sameWR:{R == Layout.resources(~S,resources) : Type},~grants:Permission.Relations<S,resources>,+context:Context.Context<S,R,resources,sameWR>,permission:Permission.Permission,world:W.World<S,Layout.columns(~S,layout),R,E>,buffer:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick) -> W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>:
  match buffer:
    case Buffer.Buffer{entries,receipts}:restored(~S,~R,~E,~layout,~route,drain(~S,~R,~E,~layout,~route,~resources,~sameWR,~grants,context,permission,entries,world,tick,receipts))
