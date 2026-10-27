import Base
import ./schema.bend as D
import ./system.bend as Decay
import ./spawn.bend as Spawn
import ./enabled.bend as Enabled
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as System
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick

def Nodes() -> Type:Product.Owner<Spawn.Node(),Decay.Node()>
def State() -> Type:App.State<Root.Storage<D.Schema,D.components(),D.resources(),Unit>,Nodes(),Enabled.Binding(),Unit>
def Application() -> Type:Scheduled.Scheduled<State()>
def dispatch(nodes:Nodes(),world:D.World(),ids:List<&2,U32>) -> IO(Execution.RunResult<D.Schema,D.components(),D.resources(),Unit,Nodes(),String,Unit>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~D.Schema,~D.components(),~D.resources(),~Unit,~String,~Unit,Spawn.Node(),Decay.Node(),ids,world,Tree.GeneralizedPair{Author.compile(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~Spawn.compilation(),left),Tree.compile_retained_generalized_leaf(~D.Schema,~D.components(),~D.resources(),~Unit,~String,~Unit,~Decay.Ops,~Unit,~Decay.kernel,~Decay.body,~Decay.compiled(),right)})
def pending_result(right:Decay.Node(),result:D.World() & (Spawn.Node() & Bool)) -> D.World() & (Nodes() & Bool):
  match result:
    case (world,(left,pending)):(world,(Product.Owner{left,right},pending))
def pending(ids:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & Bool):
  match nodes:
    case Product.Owner{left,right}:pending_result(right,Author.pending(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,ids,world,left))
def published(right:Decay.Node(),result:D.World() & Spawn.Node()) -> D.World() & Nodes():
  match result:
    case (world,left):(world,Product.Owner{left,right})
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:D.World(),nodes:Nodes()) -> D.World() & Nodes():
  match nodes:
    case Product.Owner{left,right}:published(right,Author.publish(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},~Cmd.checked_relations(~D.Schema,~D.resources(),Cmd.compiled_permission(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation())),~Cmd.construction_selection(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation()),ids,tick,world,left))
def collected(right:Decay.Node(),result:Spawn.Node() & List<&2,U32>) -> Nodes() & List<&2,U32>:
  match result:
    case (left,ids):(Product.Owner{left,right},ids)
def collect(ids:List<&2,U32>,nodes:Nodes()) -> Nodes() & List<&2,U32>:
  match nodes:
    case Product.Owner{left,right}:collected(right,Author.collect(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,ids,left))
def apply(ids:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & List<&2,U32>):
  Publication.apply(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Nodes(),~pending,~publish,~collect,ids,world,nodes)
def run(app:Application()) -> IO(Application() & App.Report<String,Unit>):
  Root.run(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Enabled.Binding(),~Unit,~String,~Unit,~dispatch,~Conditions.retained_leaf_dispatch(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Enabled.Ops,~Unit,~String,~Enabled.kernel,~Enabled.body,~Enabled.construction()),~Enabled.handle,~apply,app)
def configure(automatic:Bool,app:Application()) -> Application():Scheduled.configure(~State(),Settings.Settings{automatic,False{},[],[]},app)

def Compilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops)>
def Owner() -> Type:Cmd.Owner<D.Schema,Decay.C(),Decay.R(),Unit,D.components(),D.resources(),Spawn.route(),Spawn.Ops,Spawn.User,String,Unit,Spawn.declaration,Spawn.body>
def Binding() -> Type:Scope.CompiledBinding<Compilation(),Owner()>
def Peer() -> Type:Sys.Owner<D.Schema,D.Columns(),Decay.C(),Decay.R(),Unit,Decay.Ops,Unit,String,Unit,Decay.kernel,Decay.body>
def PeerCompilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Decay.Ops>
def PeerBinding() -> Type:Scope.CompiledBinding<PeerCompilation(),Peer()>
def build(world:D.World(),left:Binding(),right:PeerBinding(),guard:Enabled.Binding()) -> Application():
  match left right guard:
    case Scope.CompiledBinding{lc,Cmd.Owner{Sys.Owner{ln,+lid,lname,la,lt,ll}}} Scope.CompiledBinding{rc,Sys.Owner{rn,+rid,rname,ra,rt,rl}} Scope.CompiledBinding{gc,Sys.Owner{gn,+gid,gname,ga,gt,gl}}:
      configure(False{},Root.build(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Enabled.Binding(),~Unit,~String,~Conditions.retained_leaf_dispatch(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Enabled.Ops,~Unit,~String,~Enabled.kernel,~Enabled.body,~Enabled.construction()),~Enabled.available,world,Tree.generalized_pair_facts(Spawn.Node(),Decay.Node(),Author.facts(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,Scope.CompiledBinding{lc,Cmd.Owner{Sys.Owner{ln,lid,lname,la,lt,ll}}}),Tree.generalized_leaf_facts(~D.Schema,~D.components(),~D.resources(),~Unit,~String,~Unit,~Decay.Ops,~Unit,~Decay.kernel,~Decay.body,Scope.CompiledBinding{rc,Sys.Owner{rn,rid,rname,ra,rt,rl}})),Conditions.compile_retained_leaf(~String,~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Enabled.Ops,~Unit,~Enabled.kernel,~Enabled.body,~Enabled.construction(),Scope.CompiledBinding{gc,Sys.Owner{gn,gid,gname,ga,gt,gl}}),Unit{},[Plan.Edge{lid,rid}],[App.Binding{rid,gid}]))
