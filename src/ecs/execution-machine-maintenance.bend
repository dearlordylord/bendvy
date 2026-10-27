import Base
import ./execution-machine-state.bend as State
import ./execution-composer-layout.bend as Layout
import ./execution-parallel-root-application.bend as Schedule
import ./dependency-application.bend as App
import ./dependency-registry-program.bend as Prog
import ./dependency-executor.bend as Exec
import ./change-tick.bend as Tick
import ./world.bend as W
import ./lifecycle.bend as Life

# Closed framework resource adapter. It never sees or flushes command buffers.
# This aggregate stores State and its message generations together. Retention
# preserves the slot stamp; gameplay writes update it through resource access.
# Bevy maintains Messages separately from State:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L188-L201
def payload(~S:Data,~K:Data,~V:Data,~P:Type,~shape:{P == State.Cell<S,K,V> : Type},tick:Tick.Tick,owner:P) -> P & Unit:
  (Layout.checked_owner(State.Cell<S,K,V>,P,Equal.sym(Type,P,State.Cell<S,K,V>,shape),State.maintain(~S,~K,~V,tick,Layout.checked_owner(P,State.Cell<S,K,V>,shape,owner))),Unit{})
def restored(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},stamp:Life.Stamp,rest:Layout.resource_rest(~S,layout,route),result:Layout.stored(layout,route) & Unit) -> R:
  match result:
    case (stored,_):Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,Layout.ResourceSlot{stored,stamp}))
def selected(~S:Data,~K:Data,~V:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},tick:Tick.Tick,result:Layout.resource_rest(~S,layout,route) & Layout.ResourceSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> R:
  match result:
    case (rest,Layout.ResourceSlot{stored,stamp}):restored(~S,~R,~layout,~route,~same,stamp,rest,Layout.rewrite(~layout,~route,Unit,payload(~S,~K,~V,~Layout.payload(layout,route),~shape,tick),stored))
def resources(~S:Data,~K:Data,~V:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},tick:Tick.Tick,owner:R) -> R:
  selected(~S,~K,~V,~R,~layout,~route,~same,~shape,tick,Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,owner)))
def clocked(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},result:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E>:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},tick):W.World{namespace,allocator,store,resources(~S,~K,~V,~R,~layout,~route,~same,~shape,tick,resource),events,pending,registrations,nextSystemId,clock,lifecycle}
def world(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},value:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  clocked(~S,~K,~V,~C,~R,~E,~layout,~route,~same,~shape,W.clock(~S,~C,~R,~E,value))

# Root has already completed its selected final-deferred policy. Invalid/Stop
# preserve the actual application. Every Finished rotates exactly once, even
# when its genuine World clock equals that of the preceding empty update.
def application(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Owners,~Error,~Out),~guardDispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Guards,~Error,~Bool),~handle:Handler -> Error -> Handler & Exec.Handling,value:Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>>) -> Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>>:
  match value:
    case Schedule.Scheduled{App.Application{App.State{actual,owners,guards,handler,stateBindings},plan,bindings},rules,deferred}:Schedule.Scheduled{App.Application{App.State{world(~S,~K,~V,~C,~R,~E,~layout,~route,~same,~shape,actual),owners,guards,handler,stateBindings},plan,bindings},rules,deferred}
def completed(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Owners,~Error,~Out),~guardDispatch:Prog.Dispatch(~W.World<S,C,R,E>,~Guards,~Error,~Bool),~handle:Handler -> Error -> Handler & Exec.Handling,result:Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>> & App.Report<Error,Out>) -> Schedule.Scheduled<App.Application<W.World<S,C,R,E>,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>> & App.Report<Error,Out>:
  match result:
    case (value,App.Finished{events}):(application(~S,~K,~V,~C,~R,~E,~layout,~route,~same,~shape,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,value),App.Finished{events})
    case (value,App.Stopped{error,events}):(value,App.Stopped{error,events})
    case (value,App.Invalid{reason}):(value,App.Invalid{reason})
