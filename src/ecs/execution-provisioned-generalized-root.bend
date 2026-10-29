import Base
import ./execution-composer-layout.bend as L
import ./execution-schema-provisioning.bend as Provision
import ./execution-schema-provisioning-world.bend as Preflight
import ./execution-relation-failure-root-completion.bend as Completion
import ./execution-generalized-root-application.bend as General
import ./execution-parallel-root-application.bend as Root
import ./execution-resource-query-execution.bend as Execution
import ./dependency-application.bend as App
import ./dependency-executor.bend as Exec
import ./execution-relation-context.bend as Context
import ./world.bend as W

# The Root supplies its same retained schema declaration to the framework's
# publication factory. No runtime World/Seed/Reader is stored in this factory.
def PublicationFactory(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Nodes:Type,~Seed:Type) -> Type:
  @-blueprint:Provision.Blueprint<S,resources,Seed> -> List<&2,U32> -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> -> Nodes -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Nodes & List<&2,U32>)
def run_bound(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Seed:Type,~blueprint:Provision.Blueprint<S,resources,Seed>,~Nodes:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Nodes -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> -> List<&2,U32> -> IO(Execution.RunResult<S,components,resources,E,Nodes,Error,Out>),~guardDispatch:Guards -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> -> U32 -> IO(Guards & (W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Exec.Invocation<Error,Bool>)),~handle:Handler -> Error -> Handler & Exec.Handling,~publish:PublicationFactory(~S,~components,~resources,~E,~Nodes,~Seed),bound:Provision.Bound<S,L.resources(~S,resources),resources,{==},Seed,blueprint,Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>>) -> IO(Provision.Bound<S,L.resources(~S,resources),resources,{==},Seed,blueprint,Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>> & Context.RunReport<App.Report<Error,Out>>):
  match bound:
    case Provision.Bound{Context.Bound{+context,Root.Scheduled{App.State{General.Present{world,displaced},nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}}}:Root.mapped(Context.Bound<S,L.resources(~S,resources),resources,{==},Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>> & Context.RunReport<App.Report<Error,Out>>,Provision.Bound<S,L.resources(~S,resources),resources,{==},Seed,blueprint,Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>> & Context.RunReport<App.Report<Error,Out>>,General.checked_bound_with_completion(~S,~components,~resources,~E,~Nodes,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,~publish(blueprint),Completion.completed(~S,~components,~resources,~E,~Nodes,~Guards,~Handler,~Error,~Out,Provision.retention(~S,~resources,~Seed,blueprint)),context,nodes,guards,handler,stateBindings,displaced,plan,bindings,rules,deferred,Preflight.preflight(~S,~L.columns(~S,components),~L.resources(~S,resources),~E,~resources,~{==},~Seed,~blueprint,context,world)),result => Provision.reported(~S,~L.resources(~S,resources),~resources,~{==},~Seed,~blueprint,Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>,Context.RunReport<App.Report<Error,Out>>,result))
    case bound:IO.pure(Provision.Bound<S,L.resources(~S,resources),resources,{==},Seed,blueprint,Root.Scheduled<App.State<General.Storage<S,components,resources,E>,Nodes,Guards,Handler>>> & Context.RunReport<App.Report<Error,Out>>,(bound,Context.ContextRefused{}))
