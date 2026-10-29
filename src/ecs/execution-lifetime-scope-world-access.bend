import Base
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-command-permission.bend as Permission
import ./execution-relation-context.bend as Context
import ./execution-lifetime-scope-resource-dispatch.bend as Dispatch
import ./execution-lifetime-scope-store.bend as Store
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-relation-world-publication.bend as Publication
import ./entity-allocator.bend as Allocator
import ./change-tick.bend as Tick

def restored(-S:Data,-C:Type,-R:Type,-E:Data,-Physical:Type,same:{R == Physical : Type},frame:Publication.Frame<S,C,R,E>,result:Allocator.Allocator & (Physical & Dispatch.Outcome<S>)) -> W.World<S,C,R,E> & Dispatch.Outcome<S>:
  match frame result:
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle}, (allocator,(owners,outcome)):(W.World{namespace,allocator,columns,Layout.checked_owner(Physical,R,Equal.sym(Type,R,Physical,same),owners),events,pending,registrations,nextSystem,clock,lifecycle},outcome)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~program:Dispatch.Program(~S,~resources),context:Context.Context<S,R,resources,same>,route:Layout.Route,request:Store.Request<S>,world:W.World<S,C,R,E>,tick:Tick.Tick) -> W.World<S,C,R,E> & Dispatch.Outcome<S>:
  match context world:
    case Context.Context{expected} W.World{+namespace,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle}:restored(S,C,R,E,Layout.resources(~S,resources),same,Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},program(expected,namespace,allocator,Layout.checked_owner(R,Layout.resources(~S,resources),same,owners),route,request,tick))
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,context:Context.Context<S,R,resources,same>,route:Layout.Route,request:Store.Request<S>,world:W.World<S,C,R,E>,tick:Tick.Tick) -> W.World<S,C,R,E> & Dispatch.Outcome<S>:
  run(~S,~C,~R,~E,~resources,~same,~Permission.scopes_field(S,resources,selection),context,route,request,world,tick)
def observed(-S:Data,-C:Type,-R:Type,-E:Data,-Physical:Type,same:{R == Physical : Type},allocator:Allocator.Allocator,frame:Publication.Frame<S,C,R,E>,result:Physical & List<&2,Snapshot.GraphView<S>>) -> W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>:
  match frame result:
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle}, (owners,views):(W.World{namespace,allocator,columns,Layout.checked_owner(Physical,R,Equal.sym(Type,R,Physical,same),owners),events,pending,registrations,nextSystem,clock,lifecycle},views)
def gather(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~program:Snapshot.Program(~S,~resources),world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>:
  match world:
    case W.World{namespace,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle}:observed(S,C,R,E,Layout.resources(~S,resources),same,allocator,Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},program(Layout.checked_owner(R,Layout.resources(~S,resources),same,owners)))
def graphs(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~selection:Permission.Selection<S,resources>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Snapshot.GraphView<S>>:
  gather(~S,~C,~R,~E,~resources,~same,~Permission.snapshot_field(S,resources,selection),world)
