import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./sparse-failure-reader.bend as Reader
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
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-retention.bend as Retention
import ../../src/ecs/execution-relation-failure-root-completion.bend as Completion
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec

def Resources() -> Type:L.resources(~Reader.Schema,Actor.resources(~Reader.Schema))
def World() -> Type:W.World<Reader.Schema,Reader.WC(),Resources(),Unit>
def Nodes() -> Type:Product.Owner<Reader.Node(),Reader.Node()>
type Handler is Type:
  Handler{factory:W.Factory,receipts:List<&2,Store.Receipt<Reader.Schema>>}
def State() -> Type:App.State<General.Storage<Reader.Schema,Actor.components(),Actor.resources(~Reader.Schema),Unit>,Nodes(),Unit,Handler>
def Scheduled() -> Type:Root.Scheduled<State()>
def Application() -> Type:Context.Bound<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==},Scheduled()>
def leaf(node:Reader.Node()) -> Leaf.Leaf<Reader.Schema,Actor.components(),Actor.resources(~Reader.Schema),Unit,Reader.Node(),String,String>:
  Leaf.from_retained(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~String,~String,~Reader.Ops,~Reader.Local(),~Reader.kernel,~Reader.body,~Decl.trusted_construction_caps(~Reader.Schema,~Reader.WC(),~Reader.C(),~Reader.R(),~Reader.Ops,Reader.compiled()),node)
def dispatch(nodes:Nodes(),world:World(),ids:List<&2,U32>) -> IO(Execution.RunResult<Reader.Schema,Actor.components(),Actor.resources(~Reader.Schema),Unit,Nodes(),String,String>):
  match nodes:
    case Product.Owner{left,right}:Group.run_retained(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~String,~String,Reader.Node(),Reader.Node(),ids,world,leaf(left),leaf(right))
def publish(_:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(handler:Handler,_:String) -> Handler & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def catalogue() -> Retention.Catalogue<Reader.Schema,Actor.resources(~Reader.Schema)>:
  Retention.add(~Reader.Schema,~Actor.resources(~Reader.Schema),~Actor.route(),~{==},~Scene.hierarchy(~Reader.Schema),~{==},~{==},~{==},Retention.none(~Reader.Schema,~Actor.resources(~Reader.Schema)))
type Run is Type:
  Returned{app:Application(),report:Context.RunReport<App.Report<String,String>>}
  CatalogueRefused{app:Application(),catalogue:Retention.Catalogue<Reader.Schema,Actor.resources(~Reader.Schema)>}
def returned(result:Application() & Context.RunReport<App.Report<String,String>>) -> Run:
  match result:
    case (app,report):Returned{app,report}
def admitted(app:Application(),admission:Retention.Admission<Reader.Schema,Actor.resources(~Reader.Schema)>) -> IO(Run):
  match admission:
    case Retention.Refused{catalogue}:IO.pure(Run,CatalogueRefused{app,catalogue})
    case Retention.Accepted{program}:Root.mapped(Application() & Context.RunReport<App.Report<String,String>>,Run,General.run_bound_with_completion(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,~dispatch,~Conditions.empty_dispatch(~World(),~String),~handle,~publish,Completion.completed(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,program),app),returned)
def run(app:Application()) -> IO(Run):admitted(app,Retention.prepare(~Reader.Schema,~Actor.resources(~Reader.Schema),catalogue()))
def Binding() -> Type:Scope.CompiledBinding<Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Reader.Ops>,Reader.Owner()>
type Definition is Type:
  DefinitionReady{app:Application()}
  FirstRefused{context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,compilation:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Reader.Ops>,first:Reader.Local(),second:Reader.Local()}
  SecondRefused{context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,first:Binding(),compilation:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Reader.Ops>,local:Reader.Local()}
def built(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,left:Binding(),right:Binding()) -> Definition:
  DefinitionReady{Context.Bound{context,General.build(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~Conditions.empty_dispatch(~World(),~String),~available,world,Tree.generalized_pair_facts(Reader.Node(),Reader.Node(),Tree.generalized_leaf_facts(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~String,~String,~Reader.Ops,~Reader.Local(),~Reader.kernel,~Reader.body,left),Tree.generalized_leaf_facts(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~String,~String,~Reader.Ops,~Reader.Local(),~Reader.kernel,~Reader.body,right)),Conditions.compile_empty(~String,~World()),handler,[],[])}}
def second_defined(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,handler:Handler,first:Binding(),result:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Reader.Ops> & Sys.Defined<World(),Reader.Owner(),Reader.Local()>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):built(context,world,handler,first,Scope.CompiledBinding{compilation,owner})
    case (compilation,Sys.DefinitionRefused{world,local}):SecondRefused{context,world,handler,first,compilation,local}
def first_defined(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,handler:Handler,second:Reader.Local(),result:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Reader.Ops> & Sys.Defined<World(),Reader.Owner(),Reader.Local()>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):second_defined(context,handler,Scope.CompiledBinding{compilation,owner},Register.define_with_compilation(~Reader.Schema,~Reader.WC(),~Reader.C(),~Reader.R(),~Unit,~Reader.Ops,~Reader.Local(),~String,~String,~Reader.kernel,~Reader.body,~Resources(),Reader.compiled(),world,"sparse-reader-right",second))
    case (compilation,Sys.DefinitionRefused{world,first}):FirstRefused{context,world,handler,compilation,first,second}
def define(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,first:Reader.Local(),second:Reader.Local()) -> Definition:
  first_defined(context,handler,second,Register.define_with_compilation(~Reader.Schema,~Reader.WC(),~Reader.C(),~Reader.R(),~Unit,~Reader.Ops,~Reader.Local(),~String,~String,~Reader.kernel,~Reader.body,~Resources(),Reader.compiled(),world,"sparse-reader-left",first))
