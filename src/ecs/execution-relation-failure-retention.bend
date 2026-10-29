import Base
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as Store
import ./world.bend as W
import ./lifecycle.bend as Life
import ./dependency-application.bend as App
import ./dependency-executor.bend as Exec
import ./relation-types.bend as T
import ./change-tick.bend as Tick

# Closed framework resource adapter. It never sees or flushes command buffers.
# This resource stores the graph and its failure generations together. Retention
# preserves the graph slot stamp; command publication updates graph writes.
# Bevy maintains Messages separately from State:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L188-L201
def payload(~S:Data,~descriptor:T.Descriptor<S>,~P:Type,~shape:{P == Store.Store<S,descriptor> : Type},tick:Tick.Tick,owner:P) -> P & Unit:
  (Layout.checked_owner(Store.Store<S,descriptor>,P,Equal.sym(Type,P,Store.Store<S,descriptor>,shape),Store.maintained(~S,~descriptor,tick,Layout.checked_owner(P,Store.Store<S,descriptor>,shape,owner))),Unit{})
def restored(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},stamp:Life.Stamp,rest:Layout.resource_rest(~S,layout,route),result:Layout.stored(layout,route) & Unit) -> R:
  match result:
    case (stored,_):Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,Layout.ResourceSlot{stored,stamp}))
def selected(~S:Data,~descriptor:T.Descriptor<S>,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},tick:Tick.Tick,result:Layout.resource_rest(~S,layout,route) & Layout.ResourceSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> R:
  match result:
    case (rest,Layout.ResourceSlot{stored,stamp}):restored(~S,~R,~layout,~route,~same,stamp,rest,Layout.rewrite(~layout,~route,Unit,payload(~S,~descriptor,~Layout.payload(layout,route),~shape,tick),stored))
def maintain_resources(~S:Data,~descriptor:T.Descriptor<S>,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},tick:Tick.Tick,owner:R) -> R:
  selected(~S,~descriptor,~R,~layout,~route,~same,~shape,tick,Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,owner)))
def clocked(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},result:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E>:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},tick):W.World{namespace,allocator,store,maintain_resources(~S,~descriptor,~R,~layout,~route,~same,~shape,tick,resource),events,pending,registrations,nextSystemId,clock,lifecycle}
def world(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},value:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  clocked(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,W.clock(~S,~C,~R,~E,value))
# Built by trusted schema provisioning from lexical leaf witnesses. Policy alone
# never supplies a payload type. This callback owns only canonical resources.
def Program(~S:Data,~resources:Layout.Layout) -> Type:
  Tick.Tick -> Layout.resources(~S,resources) -> Layout.resources(~S,resources)
def empty(~S:Data,~resources:Layout.Layout,tick:Tick.Tick,owners:Layout.resources(~S,resources)) -> Layout.resources(~S,resources):owners

def extend(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},previous:Program(~S,~resources)) -> Program(~S,~resources):
  +tick => owners => maintain_resources(~S,~descriptor,~Layout.resources(~S,resources),~resources,~route,~{==},~payload,tick,previous(tick,owners))

type Catalogue<-S:Data,-resources:Layout.Layout> is Type:
  Catalogue{routes:List<&2,Layout.Route>,program:Program(~S,~resources)}
def none(~S:Data,~resources:Layout.Layout) -> Catalogue<S,resources>:
  Catalogue{[],empty(~S,~resources)}
def route_equal(left:Layout.Route,right:Layout.Route) -> Bool:
  match left right:
    case Layout.AtLeaf{} Layout.AtLeaf{}:True{}
    case Layout.InLeft{left} Layout.InLeft{right}:route_equal(left,right)
    case Layout.InRight{left} Layout.InRight{right}:route_equal(left,right)
    case _ _:False{}
def contains(+route:Layout.Route,routes:List<&2,Layout.Route>) -> Bool:
  match routes:
    case []:False{}
    case selected <> rest:Bool.or(route_equal(route,selected),contains(route,rest))
def admitted(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},duplicate:Bool,routes:List<&2,Layout.Route>,previous:Program(~S,~resources)) -> Catalogue<S,resources>:
  match duplicate:
    case True{}:Catalogue{routes,previous}
    case False{}:Catalogue{route <> routes,extend(~S,~resources,~route,~valid,~descriptor,~payload,~view,~protected,previous)}
def add(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},previous:Catalogue<S,resources>) -> Catalogue<S,resources>:
  match previous:
    case Catalogue{+routes,program}:admitted(~S,~resources,~route,~valid,~descriptor,~payload,~view,~protected,contains(route,routes),routes,program)
def append(prefix:Layout.Route,+suffix:Layout.Route) -> Layout.Route:
  match prefix:
    case Layout.AtLeaf{}:suffix
    case Layout.InLeft{rest}:Layout.InLeft{append(rest,suffix)}
    case Layout.InRight{rest}:Layout.InRight{append(rest,suffix)}
def leaf(policy:Policy.Policy,route:Layout.Route,routes:List<&2,Layout.Route>) -> Bool:
  match policy:
    case Policy.ProtectedRelation{_,_}:contains(route,routes)
    case Policy.Ordinary{}:True{}
    case Policy.ProtectedLifetimeScope{_}:True{}
def covers(current:Layout.Layout,+prefix:Layout.Route,+routes:List<&2,Layout.Route>) -> Bool:
  match current:
    case Layout.EmptyLayout{}:True{}
    case Layout.LayoutLeaf{_,_,_,_,policy}:leaf(policy,prefix,routes)
    case Layout.ClassifiedLayoutLeaf{_,_,_,_,_,policy}:leaf(policy,prefix,routes)
    case Layout.LayoutPair{left,right}:Bool.and(covers(left,append(prefix,Layout.InLeft{Layout.AtLeaf{}}),routes),covers(right,append(prefix,Layout.InRight{Layout.AtLeaf{}}),routes))

type MaintenanceResult<-S:Data,-resources:Layout.Layout> is Type:
  Maintained{owners:Layout.resources(~S,resources)}
  IncompleteCatalogue{owners:Layout.resources(~S,resources)}
def checked(~S:Data,~resources:Layout.Layout,complete:Bool,tick:Tick.Tick,program:Program(~S,~resources),owners:Layout.resources(~S,resources)) -> MaintenanceResult<S,resources>:
  match complete:
    case False{}:IncompleteCatalogue{owners}
    case True{}:Maintained{program(tick,owners)}
def apply(~S:Data,~resources:Layout.Layout,tick:Tick.Tick,catalogue:Catalogue<S,resources>,owners:Layout.resources(~S,resources)) -> MaintenanceResult<S,resources>:
  match catalogue:
    case Catalogue{routes,program}:checked(~S,~resources,covers(resources,Layout.AtLeaf{},routes),tick,program,owners)

# Root setup admits the whole schema catalogue before executing any system.
# A partial catalogue retains the callback and manifest rather than maintaining
# only the convenient subset. Accepted programs are trusted framework evidence.
type Admission<-S:Data,-resources:Layout.Layout> is Type:
  Accepted{program:Program(~S,~resources)}
  Refused{catalogue:Catalogue<S,resources>}
def preparation(~S:Data,~resources:Layout.Layout,complete:Bool,routes:List<&2,Layout.Route>,program:Program(~S,~resources)) -> Admission<S,resources>:
  match complete:
    case False{}:Refused{Catalogue{routes,program}}
    case True{}:Accepted{program}
def prepare(~S:Data,~resources:Layout.Layout,catalogue:Catalogue<S,resources>) -> Admission<S,resources>:
  match catalogue:
    case Catalogue{+routes,program}:preparation(~S,~resources,covers(resources,Layout.AtLeaf{},routes),routes,program)

def retained_world(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},program:Program(~S,~resources),result:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E>:
  match result:
    case (W.World{namespace,allocator,columns,resource,events,pending,registrations,nextSystemId,clock,lifecycle},tick):W.World{namespace,allocator,columns,Layout.checked_owner(Layout.resources(~S,resources),R,Equal.sym(Type,R,Layout.resources(~S,resources),same),program(tick,Layout.checked_owner(R,Layout.resources(~S,resources),same,resource))),events,pending,registrations,nextSystemId,clock,lifecycle}
# This is an overall Root completion callback, after final deferred policy.
# It rotates on Finished even with finalApply=false or an unchanged clock, and
# never advances a Reader, graph cache, resource stamp, sequence or reader ID.
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,program:Program(~S,~resources),result:Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>) -> Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>:
  match result:
    case Exec.Finished{App.State{world,owners,guards,handler,bindings},events}:Exec.Finished{App.State{retained_world(~S,~C,~R,~E,~resources,~same,program,W.clock(~S,~C,~R,~E,world)),owners,guards,handler,bindings},events}
    case Exec.Stopped{state,error,events}:Exec.Stopped{state,error,events}
    case Exec.Invalid{state,reason}:Exec.Invalid{state,reason}
