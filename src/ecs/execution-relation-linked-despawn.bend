import Base
import ./world.bend as W
import ./entity-allocator.bend as Allocator
import ./entity-key.bend as Key
import ./execution-composer-layout.bend as Layout
import ./execution-command-buffer.bend as Buffer
import ./execution-command-permission.bend as Permission
import ./execution-relation-context.bend as Context
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-lifetime-scope-coverage.bend as Coverage
import ./execution-lifetime-scope-cleanup.bend as Cleanup
import ./execution-lifetime-scope-world-access.bend as Access
import ./execution-lifetime-scope-store.bend as Store
import ./execution-lifetime-scope-resource-dispatch.bend as Dispatch
import ./relation-cleanup-engine.bend as Engine
import ./relation-types.bend as T
import ./change-tick.bend as Tick

def denied(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,handle:W.Handle<S>,reason:Buffer.ScopeDenial,receipts:List<Buffer.Receipt<S,P,D>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  (world,Buffer.LinkedDespawn{handle,Buffer.LinkedDenied{reason},List.reverse(&1,Buffer.Receipt<S,P,D>,receipts),[]})
def finished(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,handle:W.Handle<S>,result:Engine.Progress<S,Cleanup.State<S,C,R,E,P,D>>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case Engine.Complete{Cleanup.State{world,receipts,_,_,_}}:(world,Buffer.LinkedDespawn{handle,Buffer.LinkedComplete{},List.reverse(&1,Buffer.Receipt<S,P,D>,receipts),[]})
    case Engine.Incomplete{Cleanup.State{world,receipts,_,_,_},frames}:(world,Buffer.LinkedDespawn{handle,Buffer.LinkedPaused{},List.reverse(&1,Buffer.Receipt<S,P,D>,receipts),frames})
def after(routes:List<&2,Layout.Route>) -> Cleanup.AfterDespawn:
  match routes:
    case []:Cleanup.KeepMembership{}
    case routes:Cleanup.ForgetMembership{routes}
def start(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+handle:W.Handle<S>,+views:List<&2,Snapshot.GraphView<S>>,routes:List<&2,Layout.Route>,receipts:List<Buffer.Receipt<S,P,D>>,tick:Tick.Tick,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match handle world:
    case W.Handle{+namespace,+key} W.World{worldNamespace,Allocator.Allocator{next,+high,slots,capacity,depth,free,order},columns,resource,events,pending,registrations,nextSystem,clock,lifecycle}:finished(S,C,R,E,P,D,W.Handle{namespace,key},Engine.automatic(~S,~Cleanup.State<S,C,R,E,P,D>,~Cleanup.step_shared(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose),Cleanup.State{W.World{worldNamespace,Allocator.Allocator{next,high,slots,capacity,depth,free,order},columns,resource,events,pending,registrations,nextSystem,clock,lifecycle},receipts,after(routes),tick,False{}},U32.to_nat(high),Cleanup.edges(S,views),namespace,key,Cleanup.descriptors(S,views)))
def probe_namespace(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,allowed:Bool,handle:W.Handle<S>,receipts:List<Buffer.Receipt<S,P,D>>,next:List<Buffer.Receipt<S,P,D>> -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match allowed:
    case True{}:next(receipts,world)
    case False{}:denied(S,C,R,E,P,D,handle,Buffer.ForeignNamespace{},receipts,world)
def probe_result(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,+namespace:U32,+handle:W.Handle<S>,+route:Layout.Route,receipts:List<Buffer.Receipt<S,P,D>>,next:List<Buffer.Receipt<S,P,D>> -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>,result:W.World<S,C,R,E> & Dispatch.Outcome<S>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,Dispatch.Completed{Store.Inspected{+stored}}):probe_namespace(S,C,R,E,P,D,U32.is_eq(namespace,stored),handle,Buffer.ScopeStoreApplied{route,Store.Inspect{},Dispatch.Completed{Store.Inspected{stored}}} <> receipts,next,world)
    case (world,outcome):denied(S,C,R,E,P,D,handle,Buffer.ScopeStoreRefused{},Buffer.ScopeStoreApplied{route,Store.Inspect{},outcome} <> receipts,world)
def probe(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+context:Context.Context<S,R,resources,same>,+handle:W.Handle<S>,+namespace:U32,+views:List<&2,Snapshot.GraphView<S>>,+all:List<&2,Layout.Route>,routes:List<&2,Layout.Route>,receipts:List<Buffer.Receipt<S,P,D>>,+tick:Tick.Tick,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match routes:
    case []:start(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,handle,views,all,receipts,tick,world)
    case +route <> rest:probe_result(S,C,R,E,P,D,namespace,handle,route,receipts,receipts => world => probe(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,context,handle,namespace,views,all,rest,receipts,tick,world),Access.apply(~S,~C,~R,~E,~resources,~same,~selection,context,route,Store.Inspect{},world,tick))
def graphs_validated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),valid:Bool,context:Context.Context<S,R,resources,same>,handle:W.Handle<S>,namespace:U32,views:List<&2,Snapshot.GraphView<S>>,tick:Tick.Tick,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match valid:
    case False{}:denied(S,C,R,E,P,D,handle,Buffer.ForeignNamespace{},[],world)
    case True{}:probe(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,context,handle,namespace,views,Coverage.scope_routes(S,resources,relations),Coverage.scope_routes(S,resources,relations),[],tick,world)
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),context:Context.Context<S,R,resources,same>,handle:W.Handle<S>,tick:Tick.Tick,result:W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match context result:
    case Context.Context{+namespace}, (world,+views):graphs_validated(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,Coverage.namespaces(~S,namespace,views),Context.Context{namespace},handle,namespace,views,tick,world)
def covered(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),complete:Bool,context:Context.Context<S,R,resources,same>,handle:W.Handle<S>,tick:Tick.Tick,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match complete:
    case False{}:denied(S,C,R,E,P,D,handle,Buffer.MissingAuthority{},[],world)
    case True{}:observed(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,context,handle,tick,Access.graphs(~S,~C,~R,~E,~resources,~same,~selection,world))
def live_checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),context:Context.Context<S,R,resources,same>,handle:W.Handle<S>,tick:Tick.Tick,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,False{}):(world,Buffer.DespawnRefused{handle})
    case (world,True{}):covered(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,Bool.and(Coverage.layout(~S,~resources,resources,Layout.AtLeaf{},relations),Coverage.scopes_layout(S,resources,resources,Layout.AtLeaf{},relations)),context,handle,tick,world)
def context_checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+context:Context.Context<S,R,resources,same>,+handle:W.Handle<S>,tick:Tick.Tick,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,False{}):denied(S,C,R,E,P,D,handle,Buffer.ForeignNamespace{},[],world)
    case (world,True{}):live_checked(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,context,handle,tick,Cleanup.live(S,C,R,E,world,handle))
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+context:Context.Context<S,R,resources,same>,permission:Permission.Permission,world:W.World<S,C,R,E>,+handle:W.Handle<S>,tick:Tick.Tick) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match permission:
    case Permission.FamilyOnly{}:(world,Buffer.DespawnRefused{handle})
    case Permission.EntityStructural{}:context_checked(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,context,handle,tick,Context.matches(~S,~C,~R,~E,~resources,~same,context,world))
