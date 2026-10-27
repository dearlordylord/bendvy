import Base
import ./schema.bend as S
import ./body.bend as B
import ./audit.bend as Audit
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-group.bend as Group
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan

def Nodes() -> Type:Product.Owner<Audit.Node(),B.Node()>
def State() -> Type:App.State<General.Storage<S.Workshop,S.components(),S.resources(),Unit>,Nodes(),Unit,Unit>
def Application() -> Type:Root.Scheduled<State()>
def left(node:Audit.Node()) -> Leaf.Leaf<S.Workshop,S.components(),S.resources(),Unit,Audit.Node(),B.Error,String>:
  Leaf.from_retained(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,~Audit.Ops,~Unit,~Audit.kernel,~Audit.body,~Decl.trusted_construction_caps(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~Audit.Ops,Audit.compiled()),node)
def right(node:B.Node()) -> Leaf.Leaf<S.Workshop,S.components(),S.resources(),Unit,B.Node(),B.Error,String>:
  Leaf.from_retained(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,~B.Ops,~B.Local,~B.kernel,~B.body,~Decl.trusted_construction_caps(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~B.Ops,B.compiled()),node)
def dispatch(nodes:Nodes(),world:S.World(~S.Workshop),ids:List<&2,U32>) -> IO(Execution.RunResult<S.Workshop,S.components(),S.resources(),Unit,Nodes(),B.Error,String>):
  match nodes:
    case Product.Owner{a,b}:Group.run_retained(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,Audit.Node(),B.Node(),ids,world,left(a),right(b))
def publish(_:List<&2,U32>,world:S.World(~S.Workshop),nodes:Nodes()) -> S.World(~S.Workshop) & (Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(handler:Unit,_:B.Error) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def run(app:Application()) -> IO(Application() & App.Report<B.Error,String>):General.run(~S.Workshop,~S.components(),~S.resources(),~Unit,~Nodes(),~Unit,~Unit,~B.Error,~String,~dispatch,~Conditions.empty_dispatch(~S.World(~S.Workshop),~B.Error),~handle,~publish,app)
def AuditBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,Audit.Owner()>
def QueryBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,B.Owner()>
type Definition is Type:
  Ready{app:Application()}
  AuditRefused{world:S.World(~S.Workshop),compilation:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,local:Unit}
  QueryRefused{world:S.World(~S.Workshop),audit:AuditBinding(),compilation:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,local:B.Local}
def built(world:S.World(~S.Workshop),left:AuditBinding(),right:QueryBinding()) -> Definition:
  match left right:
    case Scope.CompiledBinding{ac,Sys.Owner{an,+aid,at,aa,ar,al}} Scope.CompiledBinding{bc,Sys.Owner{bn,+bid,bt,ba,br,bl}}:Ready{General.build(~S.Workshop,~S.components(),~S.resources(),~Unit,~Nodes(),~Unit,~Unit,~B.Error,~Conditions.empty_dispatch(~S.World(~S.Workshop),~B.Error),~available,world,Tree.generalized_pair_facts(Audit.Node(),B.Node(),Tree.generalized_leaf_facts(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,~Audit.Ops,~Unit,~Audit.kernel,~Audit.body,Scope.CompiledBinding{ac,Sys.Owner{an,aid,at,aa,ar,al}}),Tree.generalized_leaf_facts(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,~B.Ops,~B.Local,~B.kernel,~B.body,Scope.CompiledBinding{bc,Sys.Owner{bn,bid,bt,ba,br,bl}})),Conditions.compile_empty(~B.Error,~S.World(~S.Workshop)),Unit{},[Plan.Edge{aid,bid}],[])}
def query_defined(audit:AuditBinding(),result:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops> & Sys.Defined<S.World(~S.Workshop),B.Owner(),B.Local>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):built(world,audit,Scope.CompiledBinding{compilation,owner})
    case (compilation,Sys.DefinitionRefused{world,local}):QueryRefused{world,audit,compilation,local}
def audit_defined(result:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops> & Sys.Defined<S.World(~S.Workshop),Audit.Owner(),Unit>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):query_defined(Scope.CompiledBinding{compilation,owner},Register.define_with_compilation(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~Unit,~B.Ops,~B.Local,~B.Error,~String,~B.kernel,~B.body,~Unit,B.compiled(),world,"captured-query",B.Local{P.initial(1),B.Args{1},[],[]}))
    case (compilation,Sys.DefinitionRefused{world,local}):AuditRefused{world,compilation,local}
def define(world:S.World(~S.Workshop)) -> Definition:audit_defined(Register.define_with_compilation(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~Unit,~Audit.Ops,~Unit,~B.Error,~String,~Audit.kernel,~Audit.body,~Unit,Audit.compiled(),world,"audit",Unit{}))
