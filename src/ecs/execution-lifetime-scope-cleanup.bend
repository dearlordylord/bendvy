import Base
import ./world.bend as W
import ./entity-key.bend as Key
import ./entity-allocator.bend as Allocator
import ./execution-relation-world-publication.bend as WorldFrame
import ./relation-types.bend as T
import ./relation-graph.bend as Graph
import ./relation-cleanup-control.bend as Control
import ./relation-cleanup-engine.bend as Engine
import ./execution-composer-layout.bend as Layout
import ./execution-command-buffer.bend as Buffer
import ./execution-command-permission.bend as Permission
import ./execution-relation-buffer.bend as Relation
import ./execution-relation-operation.bend as Operation
import ./execution-relation-context.bend as Context
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-lifetime-scope-world-access.bend as Access
import ./execution-lifetime-scope-store.bend as Store
import ./execution-lifetime-scope-resource-dispatch.bend as Dispatch
import ./change-tick.bend as Tick

# Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 hierarchy.rs:50 deletes
# linked descendants. This adapter also returns each actual affine owner.
type State<-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type> is Type:
  State{world:W.World<S,C,R,E>,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,tick:Tick.Tick,blocked:Bool}
def Dispose(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type) -> Type:
  W.World<S,C,R,E> -> W.Handle<S> -> Tick.Tick -> W.World<S,C,R,E> & Buffer.Receipt<S,P,D>
def live_returned(-S:Data,-C:Type,-R:Type,-E:Data,same:Bool,resource:R,frame:WorldFrame.Frame<S,C,R,E>,result:Allocator.Allocator & Bool) -> W.World<S,C,R,E> & Bool:
  match frame result:
    case WorldFrame.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle}, (allocator,live):(W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystem,clock,lifecycle},Bool.and(same,live))
def live(-S:Data,-C:Type,-R:Type,-E:Data,world:W.World<S,C,R,E>,handle:W.Handle<S>) -> W.World<S,C,R,E> & Bool:
  match world handle:
    case W.World{+namespace,allocator,columns,resource,events,pending,registrations,nextSystem,clock,lifecycle} W.Handle{handleNamespace,key}:live_returned(S,C,R,E,U32.is_eq(namespace,handleNamespace),resource,WorldFrame.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},Allocator.checked(allocator,key,1))
def find(-S:Data,+descriptor:T.Descriptor<S>,views:List<&2,Snapshot.GraphView<S>>) -> Maybe<&2,Snapshot.GraphView<S>>:
  match views:
    case []:None{}
    case Snapshot.GraphView{route,+other,namespace,graph} <> rest:Bool.pick(Maybe<&2,Snapshot.GraphView<S>>,Permission.same_descriptor(S,descriptor,other),Some{Snapshot.GraphView{route,other,namespace,graph}},find(S,descriptor,rest))
def children_selected(-S:Data,key:Key.Key,found:Maybe<&2,Snapshot.GraphView<S>>) -> List<&2,Key.Key>:
  match found:
    case None{}:[]
    case Some{Snapshot.GraphView{_,descriptor,_,graph}}:Graph.inverse_erased(S,graph,descriptor,key)
def children(-S:Data,descriptor:T.Descriptor<S>,key:Key.Key,views:List<&2,Snapshot.GraphView<S>>) -> List<&2,Key.Key>:
  children_selected(S,key,find(S,descriptor,views))
def descriptors(-S:Data,views:List<&2,Snapshot.GraphView<S>>) -> List<&2,T.Descriptor<S>>:
  match views:
    case []:[]
    case Snapshot.GraphView{_,descriptor,_,_} <> rest:descriptor <> descriptors(S,rest)
def edges(-S:Data,views:List<&2,Snapshot.GraphView<S>>) -> List<&2,T.Edge<S>>:
  match views:
    case []:[]
    case Snapshot.GraphView{_,_,_,T.Graph{found,_}} <> rest:List.append(&2,T.Edge<S>,found,edges(S,rest))
def checked(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,tick:Tick.Tick,key:Key.Key,descriptors:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & Bool) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,False{}):(State{world,receipts,scopeRoute,tick,False{}},frames)
    case (world,True{}):(State{world,receipts,scopeRoute,tick,False{}},T.CleanupDescriptors{key,descriptors} <> frames)
def observed(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,tick:Tick.Tick,+key:Key.Key,+descriptor:T.Descriptor<S>,remaining:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,views):(State{world,receipts,scopeRoute,tick,False{}},T.CleanupChildren{key,descriptor,remaining,children(S,descriptor,key,views)} <> frames)
def recorded(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,tick:Tick.Tick,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & Buffer.Receipt<S,P,D>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,receipt):(State{world,receipt <> receipts,scopeRoute,tick,False{}},frames)
def forgotten(-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-D:Type,receipts:List<Buffer.Receipt<S,P,D>>,+scopeRoute:Layout.Route,tick:Tick.Tick,handle:W.Handle<S>,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & Dispatch.Outcome<S>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,result):(State{world,Buffer.ScopeStoreApplied{scopeRoute,Store.Forget{handle},result} <> receipts,scopeRoute,tick,False{}},frames)
def disposed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,namespace:U32,receipts:List<Buffer.Receipt<S,P,D>>,+scopeRoute:Layout.Route,+tick:Tick.Tick,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & Buffer.Receipt<S,P,D>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,Buffer.Despawned{+handle,removed}):forgotten(S,C,R,E,P,D,Buffer.Despawned{handle,removed} <> receipts,scopeRoute,tick,handle,frames,Access.apply(~S,~C,~R,~E,~resources,~same,~selection,Context.Context{namespace},scopeRoute,Store.Forget{handle},world,tick))
    case (world,receipt):recorded(S,C,R,E,P,D,receipts,scopeRoute,tick,frames,(world,receipt))
def unlink_selected(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,+namespace:U32,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,+tick:Tick.Tick,key:Key.Key,original:T.CleanupFrame<S>,frames:List<&2,T.CleanupFrame<S>>,world:W.World<S,C,R,E>,found:Maybe<&2,Snapshot.GraphView<S>>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match found:
    case None{}:(State{world,receipts,scopeRoute,tick,True{}},original <> frames)
    case Some{Snapshot.GraphView{route,_,_,_}}:recorded(S,C,R,E,P,D,receipts,scopeRoute,tick,frames,Relation.apply(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,Context.Context{namespace},route,Operation.Unrelate{W.Handle{namespace,key}},world,tick))
def unlinked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,namespace:U32,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,+tick:Tick.Tick,key:Key.Key,descriptor:T.Descriptor<S>,original:T.CleanupFrame<S>,frames:List<&2,T.CleanupFrame<S>>,result:W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match result:
    case (world,views):unlink_selected(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,namespace,receipts,scopeRoute,tick,key,original,frames,world,find(S,descriptor,views))
def interpreted(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Dispose(~S,~C,~R,~E,~P,~D),intent:Control.Intent<S>,original:T.CleanupFrame<S>,world:W.World<S,C,R,E>,receipts:List<Buffer.Receipt<S,P,D>>,scopeRoute:Layout.Route,+tick:Tick.Tick,+namespace:U32) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match intent:
    case Control.Check{+key,descriptors,frames}:checked(S,C,R,E,P,D,receipts,scopeRoute,tick,key,descriptors,frames,live(S,C,R,E,world,W.Handle{namespace,key}))
    case Control.Observe{key,descriptor,remaining,frames}:observed(S,C,R,E,P,D,receipts,scopeRoute,tick,key,descriptor,remaining,frames,Access.graphs(~S,~C,~R,~E,~resources,~same,~selection,world))
    case Control.Unrelate{key,descriptor,frames}:unlinked(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,namespace,receipts,scopeRoute,tick,key,descriptor,original,frames,Access.graphs(~S,~C,~R,~E,~resources,~same,~selection,world))
    case Control.Finish{key,frames}:disposed(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,namespace,receipts,scopeRoute,tick,frames,dispose(world,W.Handle{namespace,key},tick))
    case Control.Continue{frames}:(State{world,receipts,scopeRoute,tick,False{}},frames)
def step_shared(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Dispose(~S,~C,~R,~E,~P,~D),+frame:T.CleanupFrame<S>,state:State<S,C,R,E,P,D>,+namespace:U32,descriptors:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  match state:
    case State{world,receipts,scopeRoute,tick,True{}}:(State{world,receipts,scopeRoute,tick,True{}},frame <> frames)
    case State{world,receipts,scopeRoute,tick,False{}}:interpreted(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,Control.next(S,frame,descriptors,frames),frame,world,receipts,scopeRoute,tick,namespace)
def step(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Dispose(~S,~C,~R,~E,~P,~D),frame:T.CleanupFrame<S>,state:State<S,C,R,E,P,D>,+namespace:U32,descriptors:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>) -> State<S,C,R,E,P,D> & List<&2,T.CleanupFrame<S>>:
  step_shared(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,frame,state,namespace,descriptors,frames)
def member_frames(~S:Data,members:List<&2,Key.Key>) -> List<&2,T.CleanupFrame<S>>:
  match members:
    case []:[]
    case key <> rest:T.CleanupEnter{key} <> member_frames(~S,rest)
def continued(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,members:List<&2,Key.Key>,result:Engine.Progress<S,State<S,C,R,E,P,D>>,next:State<S,C,R,E,P,D> -> Engine.Progress<S,State<S,C,R,E,P,D>>) -> Engine.Progress<S,State<S,C,R,E,P,D>>:
  match result:
    case Engine.Incomplete{state,frames}:Engine.Incomplete{state,List.append(&2,T.CleanupFrame<S>,frames,member_frames(~S,members))}
    case Engine.Complete{state}:next(state)
def members_step(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,~dispose:Dispose(~S,~C,~R,~E,~P,~D),+nodes:Nat,+originalEdges:List<&2,T.Edge<S>>,+namespace:U32,+descriptors:List<&2,T.Descriptor<S>>,members:List<&2,Key.Key>,state:State<S,C,R,E,P,D>) -> Engine.Progress<S,State<S,C,R,E,P,D>>:
  match members:
    case []:Engine.Complete{state}
    case key <> +rest:continued(~S,~C,~R,~E,~P,~D,rest,Engine.automatic(~S,~State<S,C,R,E,P,D>,~step(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose),state,nodes,originalEdges,namespace,key,descriptors),state => members_step(~S,~C,~R,~E,~P,~D,~resources,~same,~selection,~dispose,nodes,originalEdges,namespace,descriptors,rest,state))
