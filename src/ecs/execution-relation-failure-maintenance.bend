import Base
import ./execution-relation-store.bend as Store
import ./execution-relation-failure-retention.bend as Retention
import ./relation-types.bend as T
import ./execution-composer-layout.bend as Layout
import ./execution-parallel-root-application.bend as Schedule
import ./dependency-application.bend as App
import ./world.bend as W
# Only an overall Finished report permits channel rotation. Stop and Invalid
# return the actual Scheduled owner unchanged, including pending commands.
def application(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},~Owners:Type,~Guards:Type,~Handler:Type,value:Schedule.Scheduled<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>>) -> Schedule.Scheduled<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>>:
  match value:
    case Schedule.Scheduled{App.State{actual,owners,guards,handler,stateBindings},plan,bindings,rules,deferred}:Schedule.Scheduled{App.State{Retention.world(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,actual),owners,guards,handler,stateBindings},plan,bindings,rules,deferred}
def completed(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Store.Store<S,descriptor> : Type},~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,result:Schedule.Scheduled<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & App.Report<Error,Out>) -> Schedule.Scheduled<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & App.Report<Error,Out>:
  match result:
    case (value,App.Finished{events}):(application(~S,~descriptor,~C,~R,~E,~layout,~route,~same,~shape,~Owners,~Guards,~Handler,value),App.Finished{events})
    case (value,App.Stopped{error,events}):(value,App.Stopped{error,events})
    case (value,App.Invalid{reason}):(value,App.Invalid{reason})
