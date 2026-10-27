import Base
import ./execution-relation-store.bend as Store
import ./relation-types.bend as T
import ./execution-composer-layout.bend as Layout
import ./execution-parallel-root-application.bend as Schedule
import ./dependency-application.bend as App
import ./dependency-registry-program.bend as Prog
import ./dependency-executor.bend as Exec
import ./change-tick.bend as Tick
import ./world.bend as W
import ./lifecycle.bend as Life

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
def resources(~S:Data,~descriptor:T.Descriptor<S>,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},tick:Tick.Tick,owner:R) -> R:
  selected(~S,~descriptor,~R,~layout,~route,~same,~shape,tick,Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,owner)))
def clocked(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},result:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E>:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},tick):W.World{namespace,allocator,store,resources(~S,~descriptor,~R,~layout,~route,~same,~shape,tick,resource),events,pending,registrations,nextSystemId,clock,lifecycle}
def world(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},value:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  clocked(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,W.clock(~S,~C,~R,~E,value))

# Root has already completed its selected final-deferred policy. Invalid/Stop
# preserve the actual application. Every Finished rotates exactly once, even
# when its genuine World clock equals that of the preceding empty update.
def application(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Owners,~Error,~Out),~guardDispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Guards,~Error,~Bool),~handle:Handler -> Error -> Handler & Exec.Handling,value:Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>>) -> Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>>:
  match value:
    case Schedule.Scheduled{App.Application{App.State{actual,owners,guards,handler,stateBindings},plan,bindings},rules,deferred}:Schedule.Scheduled{App.Application{App.State{world(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,actual),owners,guards,handler,stateBindings},plan,bindings},rules,deferred}
def completed(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Owners,~Error,~Out),~guardDispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Guards,~Error,~Bool),~handle:Handler -> Error -> Handler & Exec.Handling,result:Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>> & App.Report<Error,Out>) -> Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>> & App.Report<Error,Out>:
  match result:
    case (value,App.Finished{events}):(application(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,value),App.Finished{events})
    case (value,App.Stopped{error,events}):(value,App.Stopped{error,events})
    case (value,App.Invalid{reason}):(value,App.Invalid{reason})
