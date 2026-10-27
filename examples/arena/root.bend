import Base
import ./schema.bend as D
import ./system.bend as Decay
import ./spawn.bend as Spawn
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
import ../../src/ecs/dependency-executor.bend as Exec

def handle(local:Unit,_:String) -> Unit & Exec.Handling:(local,Exec.Escalate{})
def available(_:String) -> Bool:True{}

def Nodes() -> Type:Product.Owner<Spawn.Node(),Decay.Node()>
def State() -> Type:App.State<Root.Storage<D.Schema,D.components(),D.resources(),Unit>,Nodes(),Unit,Unit>
def Application() -> Type:Scheduled.Scheduled<State()>
def dispatch(nodes:Nodes(),world:D.World(),ids:List<&2,U32>) -> IO(Execution.RunResult<D.Schema,D.components(),D.resources(),Unit,Nodes(),String,Unit>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~D.Schema,~D.components(),~D.resources(),~Unit,~String,~Unit,Spawn.Node(),Decay.Node(),ids,world,Tree.GeneralizedPair{Author.compile(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~Spawn.compilation(),left),Author.compile(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,~Decay.compilation(),right)})
def pending_right(left:Spawn.Node(),pending:Bool,result:D.World() & (Decay.Node() & Bool)) -> D.World() & (Nodes() & Bool):
  match result:
    case (world,(right,other)):(world,(Product.Owner{left,right},Bool.or(pending,other)))
def pending_result(ids:List<&2,U32>,right:Decay.Node(),result:D.World() & (Spawn.Node() & Bool)) -> D.World() & (Nodes() & Bool):
  match result:
    case (world,(left,pending)):pending_right(left,pending,Author.pending(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,ids,world,right))
def pending(selected:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & Bool):
  match nodes:
    case Product.Owner{left,right}:
      +ids:List<&2,U32> = selected
      pending_result(ids,right,Author.pending(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,ids,world,left))
def published_right(left:Spawn.Node(),result:D.World() & Decay.Node()) -> D.World() & Nodes():
  match result:
    case (world,right):(world,Product.Owner{left,right})
def published(ids:List<&2,U32>,tick:Tick.Tick,right:Decay.Node(),result:D.World() & Spawn.Node()) -> D.World() & Nodes():
  match result:
    case (world,left):published_right(left,Author.publish(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,~{==},~Cmd.checked_relations(~D.Schema,~D.resources(),Cmd.compiled_permission(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Decay.route(),~Decay.Ops,Decay.compilation())),~Cmd.construction_selection(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Decay.route(),~Decay.Ops,Decay.compilation()),ids,tick,world,right))
def publish(selected:List<&2,U32>,stamp:Tick.Tick,world:D.World(),nodes:Nodes()) -> D.World() & Nodes():
  match nodes:
    case Product.Owner{left,right}:
      +ids:List<&2,U32> = selected
      +tick:Tick.Tick = stamp
      published(ids,tick,right,Author.publish(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},~Cmd.checked_relations(~D.Schema,~D.resources(),Cmd.compiled_permission(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation())),~Cmd.construction_selection(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation()),ids,tick,world,left))
def collected_right(left:Spawn.Node(),ids:List<&2,U32>,result:Decay.Node() & List<&2,U32>) -> Nodes() & List<&2,U32>:
  match result:
    case (right,other):(Product.Owner{left,right},List.append(&2,U32,ids,other))
def collected(selected:List<&2,U32>,right:Decay.Node(),result:Spawn.Node() & List<&2,U32>) -> Nodes() & List<&2,U32>:
  match result:
    case (left,ids):collected_right(left,ids,Author.collect(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,selected,right))
def collect(selected:List<&2,U32>,nodes:Nodes()) -> Nodes() & List<&2,U32>:
  match nodes:
    case Product.Owner{left,right}:
      +ids:List<&2,U32> = selected
      collected(ids,right,Author.collect(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,ids,left))
def apply(ids:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & List<&2,U32>):
  Publication.apply(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Nodes(),~pending,~publish,~collect,ids,world,nodes)
def run(app:Application()) -> IO(Application() & App.Report<String,Unit>):
  Root.run(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Unit,~Unit,~String,~Unit,~dispatch,~Conditions.empty_dispatch(~D.World(),~String),~handle,~apply,app)
def configure(automatic:Bool,app:Application()) -> Application():Scheduled.configure(~State(),Settings.Settings{automatic,True{},[],[]},app)
def prepare(app:Application()) -> Application():Scheduled.configure(~State(),Settings.Settings{False{},True{},[],[]},app)

def Compilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops)>
def Owner() -> Type:Cmd.Owner<D.Schema,Decay.C(),Decay.R(),Unit,D.components(),D.resources(),Spawn.route(),Spawn.Ops,Spawn.User,String,Unit,Spawn.declaration,Spawn.body>
def Binding() -> Type:Scope.CompiledBinding<Compilation(),Owner()>
def Peer() -> Type:Cmd.Owner<D.Schema,Decay.C(),Decay.R(),Unit,D.components(),D.resources(),Decay.route(),Decay.Ops,Decay.User,String,Unit,Decay.declaration,Decay.body>
def PeerCompilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~Decay.route(),~Decay.Ops)>
def PeerBinding() -> Type:Scope.CompiledBinding<PeerCompilation(),Peer()>
def build(world:D.World(),left:Binding(),right:PeerBinding()) -> Application():
  match left right:
    case Scope.CompiledBinding{lc,Cmd.Owner{Sys.Owner{ln,+lid,lname,la,lt,ll}}} Scope.CompiledBinding{rc,Cmd.Owner{Sys.Owner{rn,+rid,rname,ra,rt,rl}}}:
      configure(True{},Root.build(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Unit,~Unit,~String,~Conditions.empty_dispatch(~D.World(),~String),~available,world,Tree.generalized_pair_facts(Spawn.Node(),Decay.Node(),Author.facts(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,Scope.CompiledBinding{lc,Cmd.Owner{Sys.Owner{ln,lid,lname,la,lt,ll}}}),Author.facts(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,Scope.CompiledBinding{rc,Cmd.Owner{Sys.Owner{rn,rid,rname,ra,rt,rl}}})),Conditions.compile_empty(~String,~D.World()),Unit{},[Plan.Edge{lid,rid}],[]))
