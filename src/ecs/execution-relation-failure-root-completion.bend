import Base
import ./execution-relation-failure-retention.bend as Retention
import ./execution-composer-layout.bend as Layout
import ./execution-generalized-root-application.bend as Root
import ./dependency-application.bend as App
import ./dependency-executor.bend as Exec
import ./world.bend as W

# Compose with the existing whole-update lifecycle policy. Refused cuts retain
# their actual inventories and cannot be treated as a World for maintenance.
def maintained(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~Nodes:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,program:Retention.Program(~S,~resources),result:Exec.ExecutionResult<App.State<Root.Storage<S,components,resources,E>,Nodes,Guards,Handler>,String,Error,Out>) -> Exec.ExecutionResult<App.State<Root.Storage<S,components,resources,E>,Nodes,Guards,Handler>,String,Error,Out>:
  match result:
    case Exec.Finished{App.State{Root.Present{world,displaced},nodes,guards,handler,bindings},events}:Exec.Finished{App.State{Root.Present{Retention.retained_world(~S,~Layout.columns(~S,components),~Layout.resources(~S,resources),~E,~resources,~{==},program,W.clock(~S,~Layout.columns(~S,components),~Layout.resources(~S,resources),~E,world)),displaced},nodes,guards,handler,bindings},events}
    case result:result

def completed(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~Nodes:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,program:Retention.Program(~S,~resources),result:Exec.ExecutionResult<App.State<Root.Storage<S,components,resources,E>,Nodes,Guards,Handler>,String,Error,Out>) -> Exec.ExecutionResult<App.State<Root.Storage<S,components,resources,E>,Nodes,Guards,Handler>,String,Error,Out>:
  maintained(~S,~components,~resources,~E,~Nodes,~Guards,~Handler,~Error,~Out,program,Root.completed(~S,~components,~resources,~E,~Nodes,~Guards,~Handler,~Error,~Out,result))
