import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ./app-a-systems.bend as Systems
import ./app-a-condition.bend as Condition
import ./app-a-captures.bend as Captures
import ./app-a-inspection.bend as Inspect
import ./app-a-group.bend as Group
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def Storage() -> Type:General.Storage<P.AuditWorkshop,D.components(),Author.resources(),Unit>
def ApplicationState() -> Type:App.State<Storage(),Captures.Nodes(),Condition.Owner(),Unit>
def Application() -> Type:Root.Scheduled<ApplicationState()>
def dispatch(nodes:Captures.Nodes(),world:Systems.World(),ids:List<&2,U32>) -> IO(Execution.RunResult<P.AuditWorkshop,D.components(),Author.resources(),Unit,Captures.Nodes(),String,String>):Group.run(ids,world,nodes)
def publish(ids:List<&2,U32>,world:Systems.World(),nodes:Captures.Nodes()) -> Systems.World() & (Captures.Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def run(app:Application()) -> IO(Application() & App.Report<String,String>):
  General.run(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Captures.Nodes(),~Condition.Owner(),~Unit,~String,~String,~dispatch,~Condition.dispatch(),~handle,~publish,app)
def facts(writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding()) -> Tree.GeneralizedFacts<Captures.Nodes()>:
  Tree.generalized_pair_facts(Systems.WriterNode(),Product.Owner<Systems.QueryNode(),Systems.ReaderNode()>,Tree.generalized_leaf_facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.WriterOps,~Systems.WriterLocal,~Systems.writer_kernel,~Systems.writer_body,writer),Tree.generalized_pair_facts(Systems.QueryNode(),Systems.ReaderNode(),Tree.generalized_leaf_facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.QueryOps,~Systems.QueryLocal,~Systems.query_kernel,~Systems.query_body,query),Tree.generalized_leaf_facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.ReaderOps,~Array<U32>,~Systems.reader_kernel,~Systems.reader_body,reader)))
type Definition is Type:
  Ready{application:Application()}
  RegistrationRefused{inventory:Systems.Registration}
  GuardRefused{world:Systems.World(),writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding(),local:U32}
def guard_defined(writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding(),writerId:U32,queryId:U32,readerId:U32,result:Sys.Defined<Systems.World(),Condition.Owner(),U32>) -> Definition:
  match result:
    case Sys.Defined{world,Sys.Owner{namespace,+id,name,access,cursor,local}}:Ready{General.build(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Captures.Nodes(),~Condition.Owner(),~Unit,~String,~Condition.dispatch(),~available,world,facts(writer,query,reader),Condition.registry(Sys.Owner{namespace,id,name,access,cursor,local}),Unit{},[Plan.Edge{writerId,readerId}],[App.Binding{queryId,id}])}
    case Sys.DefinitionRefused{world,local}:GuardRefused{world,writer,query,reader,local}
def writer_id(binding:Systems.WriterBinding()) -> Systems.WriterBinding() & U32:
  match binding:
    case Scope.CompiledBinding{compilation,Sys.Owner{namespace,+id,name,access,cursor,local}}:(Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,access,cursor,local}},id)
def reader_id(binding:Systems.ReaderBinding()) -> Systems.ReaderBinding() & U32:
  match binding:
    case Scope.CompiledBinding{compilation,Sys.Owner{namespace,+id,name,access,cursor,local}}:(Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,access,cursor,local}},id)
def ordered(world:Systems.World(),query:Systems.QueryBinding(),queryId:U32,writer:Systems.WriterBinding() & U32,reader:Systems.ReaderBinding() & U32) -> Definition:
  match writer reader:
    case (writer,writerId), (reader,readerId):guard_defined(writer,query,reader,writerId,queryId,readerId,Condition.define(world))
def registered(result:Systems.Registration) -> Definition:
  match result:
    case Systems.Registered{world,writer,Scope.CompiledBinding{compilation,Sys.Owner{namespace,+id,name,access,cursor,local}},reader}:ordered(world,Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,access,cursor,local}},id,writer_id(writer),reader_id(reader))
    case inventory:RegistrationRefused{inventory}
def define(world:Systems.World(),target:W.Handle<P.AuditWorkshop>) -> Definition:registered(Systems.define(world,target))
def snapshot_returned(displaced:List<&1,Schema.displacements(~P.AuditWorkshop,D.components())>,guard:Condition.Owner(),handler:Unit,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,rules:Registration.Rules,deferred:Root.Deferred,worldResult:Systems.World() & String,nodeResult:Captures.Nodes() & String) -> Application() & String:
  match worldResult nodeResult:
    case (world,values), (nodes,captures):(Root.Scheduled{App.State{General.Present{world,displaced},nodes,guard,handler,stateBindings},plan,bindings,rules,deferred},values ++ ";" ++ captures)
def snapshot(target:W.Handle<P.AuditWorkshop>,app:Application()) -> Application() & String:
  match app:
    case Root.Scheduled{App.State{General.Present{world,displaced},nodes,guard,handler,stateBindings},plan,bindings,rules,deferred}:snapshot_returned(displaced,guard,handler,stateBindings,plan,bindings,rules,deferred,Inspect.paired(world,target),Captures.nodes(nodes))
    case app:(app,"refused-storage-inventory-retained")
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/ran/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/body-error/" ++ error ++ "/" ++ out
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def report(value:App.Report<String,String>) -> String:
  match value:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case App.Stopped{error,_}:"stopped:" ++ error
    case App.Invalid{_}:"invalid"
