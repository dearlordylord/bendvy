import Base
import ./world.bend as W
import ./entity-allocator.bend as Allocator
import ./entity-key.bend as Key
import ./lifetime-scope.bend as Scope
import ./relation-types.bend as T
import ./relation-cleanup-engine.bend as Engine
import ./execution-composer-layout.bend as Layout
import ./execution-command-buffer.bend as Buffer
import ./execution-command-permission.bend as Permission
import ./execution-relation-context.bend as Context
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-lifetime-scope-command.bend as Commands
import ./execution-lifetime-scope-store.bend as Store
import ./execution-lifetime-scope-resource-dispatch.bend as Dispatch
import ./execution-lifetime-scope-world-access.bend as Access
import ./execution-lifetime-scope-coverage.bend as Coverage
import ./execution-lifetime-scope-cleanup.bend as Cleanup
import ./change-tick.bend as Tick

def denied(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,route:Layout.Route,operation:Commands.Operation<S>,reason:Buffer.ScopeDenial,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  (world,Buffer.ScopePublished{route,operation,Buffer.ScopeDenied{reason},[],[]})
def completed(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,route:Layout.Route,operation:Commands.Operation<S>,result:Engine.Progress<S,Cleanup.State<S,C,R,E,P,D>>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case Engine.Complete{Cleanup.State{world,receipts,_,_,_}}:(world,Buffer.ScopePublished{route,operation,Buffer.ScopeComplete{},List.reverse(&1,Buffer.Receipt<S,P,D>,receipts),[]})
    case Engine.Incomplete{Cleanup.State{world,receipts,_,_,_},frames}:(world,Buffer.ScopePublished{route,operation,Buffer.ScopePaused{},List.reverse(&1,Buffer.Receipt<S,P,D>,receipts),frames})
def start(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+route:Layout.Route,scope:Scope.Scope<S>,members:List<&2,Key.Key>,+views:List<&2,Snapshot.GraphView<S>>,tick:Tick.Tick,receipts:List<Buffer.Receipt<S,P,D>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match world:
    case W.World{+namespace,Allocator.Allocator{next,+high,slots,capacity,depth,free,order},columns,resource,events,pending,registrations,nextSystem,clock,lifecycle}:completed(S,C,R,E,P,D,route,Commands.Cleanup{scope},Cleanup.members_step(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,U32.to_nat(high),Cleanup.edges(S,views),namespace,Cleanup.descriptors(S,views),members,Cleanup.State{W.World{namespace,Allocator.Allocator{next,high,slots,capacity,depth,free,order},columns,resource,events,pending,registrations,nextSystem,clock,lifecycle},receipts,Cleanup.ForgetMembership{[route]},tick,False{}}))
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+route:Layout.Route,+scope:Scope.Scope<S>,views:List<&2,Snapshot.GraphView<S>>,tick:Tick.Tick,result:W.World<S,C,R,E> & Dispatch.Outcome<S>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,Dispatch.Completed{Store.Selection{Store.Selected{selectedScope,+members}}}):start(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,route,scope,members,views,tick,[Buffer.ScopeStoreApplied{route,Store.Select{scope},Dispatch.Completed{Store.Selection{Store.Selected{selectedScope,members}}}}],world)
    case (world,result):(world,Buffer.ScopePublished{route,Commands.Cleanup{scope},Buffer.ScopeDenied{Buffer.ScopeStoreRefused{}},[Buffer.ScopeStoreApplied{route,Store.Select{scope},result}],[]})
def validated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),sameNamespace:Bool,context:Context.Context<S,R,resources,same>,+route:Layout.Route,+scope:Scope.Scope<S>,views:List<&2,Snapshot.GraphView<S>>,+tick:Tick.Tick,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match sameNamespace:
    case False{}:denied(S,C,R,E,P,D,route,Commands.Cleanup{scope},Buffer.ForeignNamespace{},world)
    case True{}:selected(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,route,scope,views,tick,Access.apply(~S,~C,~R,~E,~resources,~same,~selection,context,route,Store.Select{scope},world,tick))
def graphs_observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),context:Context.Context<S,R,resources,same>,route:Layout.Route,scope:Scope.Scope<S>,tick:Tick.Tick,result:W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match context result:
    case Context.Context{+namespace}, (world,+views):validated(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,Coverage.namespaces(~S,namespace,views),Context.Context{namespace},route,scope,views,tick,world)
def cleanup_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),allowed:Bool,context:Context.Context<S,R,resources,same>,route:Layout.Route,scope:Scope.Scope<S>,world:W.World<S,C,R,E>,tick:Tick.Tick) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match allowed:
    case False{}:denied(S,C,R,E,P,D,route,Commands.Cleanup{scope},Buffer.MissingAuthority{},world)
    case True{}:graphs_observed(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,context,route,scope,tick,Access.graphs(~S,~C,~R,~E,~resources,~same,~selection,world))
def assigned(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,+route:Layout.Route,+scope:Scope.Scope<S>,+handle:W.Handle<S>,result:W.World<S,C,R,E> & Dispatch.Outcome<S>) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,Dispatch.Completed{Store.Assignment{Store.Assigned{actualScope,actualHandle}}}):(world,Buffer.ScopePublished{route,Commands.Assign{scope,handle},Buffer.ScopeComplete{},[Buffer.ScopeStoreApplied{route,Store.Assign{scope,handle},Dispatch.Completed{Store.Assignment{Store.Assigned{actualScope,actualHandle}}}}],[]})
    case (world,result):(world,Buffer.ScopePublished{route,Commands.Assign{scope,handle},Buffer.ScopeDenied{Buffer.ScopeStoreRefused{}},[Buffer.ScopeStoreApplied{route,Store.Assign{scope,handle},result}],[]})
def apply_checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+context:Context.Context<S,R,resources,same>,+route:Layout.Route,operation:Commands.Operation<S>,tick:Tick.Tick,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  match operation result:
    case operation, (world,False{}):denied(S,C,R,E,P,D,route,operation,Buffer.ForeignNamespace{},world)
    case Commands.Assign{+scope,+handle}, (world,True{}):assigned(S,C,R,E,P,D,route,scope,handle,Access.apply(~S,~C,~R,~E,~resources,~same,~selection,context,route,Store.Assign{scope,handle},world,tick))
    case Commands.Cleanup{scope}, (world,True{}):cleanup_allowed(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,Coverage.layout(~S,~resources,resources,Layout.AtLeaf{},relations),context,route,scope,world,tick)
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~relations:Permission.Relations<S,resources>,~dispose:Cleanup.Dispose(~S,~C,~R,~E,~P,~D),+context:Context.Context<S,R,resources,same>,route:Layout.Route,operation:Commands.Operation<S>,world:W.World<S,C,R,E>,tick:Tick.Tick) -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>:
  apply_checked(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~relations,~dispose,context,route,operation,tick,Context.matches(~S,~C,~R,~E,~resources,~same,context,world))
