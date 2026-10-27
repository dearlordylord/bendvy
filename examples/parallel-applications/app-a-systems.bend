import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf

def Columns() -> Type:Author.Columns()
def C() -> Type:QueryStore.owner(~P.AuditWorkshop,D.components(),QueryStore.Sparse{})
def R() -> Type:ResourceStore.owner(~P.AuditWorkshop,Author.resources(),ResourceStore.Sparse{})
def World() -> Type:W.World<P.AuditWorkshop,Columns(),L.resources(~P.AuditWorkshop,Author.resources()),Unit>
def WriterOps(Permit:Data,H:Type) -> Type:Resource.Writer<H,Array<U32>,List<&2,U32>>
def ReaderOps(Permit:Data,H:Type) -> Type:Resource.Reader<H,List<&2,U32>>
def QueryOps(Permit:Data,H:Type) -> Type:Q.GeneralWriter<P.AuditWorkshop,H,U32,U32>
def any(_:Maybe<&2,U32>) -> Bool:True{}
def writer_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & WriterOps(Permit,H):
  Build.general_resource_write(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~rw,book)
def reader_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & ReaderOps(Permit,H):
  Build.general_resource_read(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~rr,book)
def query_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & QueryOps(Permit,H):
  Build.general_query(~P.AuditWorkshop,~Columns(),~C(),~R(),~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==},~QueryStore.Sparse{},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~q,book)
def writer_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & WriterOps(Permit,H):builder(WriterOps,writer_selection(~Permit,~H,~B),book)
def reader_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & ReaderOps(Permit,H):builder(ReaderOps,reader_selection(~Permit,~H,~B),book)
def query_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & QueryOps(Permit,H):builder(QueryOps,query_selection(~Permit,~H,~B),book)
def writer_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & WriterOps(Permit,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~WriterOps,~writer_program,~Permit,~token,~H,~B,~builder,book)
def reader_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & ReaderOps(Permit,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~ReaderOps,~reader_program,~Permit,~token,~H,~B,~builder,book)
def query_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~H,~B),book:B) -> B & QueryOps(Permit,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~QueryOps,~query_program,~Permit,~token,~H,~B,~builder,book)

type WriterLocal is Type:WriterLocal{returned:List<Array<U32>>,unused:List<(Array<U32> -> Array<U32> & Array<U32>)>}
def counter(owner:Array<U32>) -> Array<U32> & Array<U32>:(P.next_counter(),owner)
def written(~Permit:Data,~H:Type,returned:List<Array<U32>>,unused:List<(Array<U32> -> Array<U32> & Array<U32>)>,result:H & ResourceStore.Edit<Array<U32>,Array<U32>>) -> Task.Task<P.AuditWorkshop,Permit,H & (WriterLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,ResourceStore.Edited{output}):Task.TDone{(scope,(WriterLocal{List.append(&1,Array<U32>,returned,[output]),unused},Sys.Success{"Counter=[21,22]"}))}
    case (scope,ResourceStore.Unchanged{operation}):Task.TDone{(scope,(WriterLocal{returned,operation <> unused},Sys.BodyError{"counter replacement refused","operation retained"}))}
def writer_caps(~Permit:Data,~H:Type,caps:WriterOps(Unit,H),scope:H,local:WriterLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (WriterLocal & Sys.Completion<String,String>)>:
  match caps local:
    case Resource.Writer{_,own,_} WriterLocal{returned,unused}:written(~Permit,~H,returned,unused,own(Array<U32>,scope,counter))
    case _ local:Task.TDone{(scope,(local,Sys.BodyError{"counter unsupported","local retained"}))}
def writer_body(~Permit:Data,~H:Type,~caps:WriterOps(Permit,H),scope:H,local:WriterLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (WriterLocal & Sys.Completion<String,String>)>:
  writer_caps(~Permit,~H,caps,scope,local)
def read_resource(~Permit:Data,~H:Type,capture:Array<U32>,result:H & ResourceStore.Lookup<List<&2,U32>>) -> Task.Task<P.AuditWorkshop,Permit,H & (Array<U32> & Sys.Completion<String,String>)>:
  match result:
    case (scope,ResourceStore.Viewed{view,_}):Task.TDone{(scope,(P.increment(U32.add(1,D.sum(view)),capture),Sys.Success{"Counter read"}))}
    case (scope,ResourceStore.LookupRefused{}):Task.TDone{(scope,(capture,Sys.BodyError{"Counter read refused","capture retained"}))}
def reader_caps(~Permit:Data,~H:Type,caps:ReaderOps(Unit,H),scope:H,capture:Array<U32>) -> Task.Task<P.AuditWorkshop,Permit,H & (Array<U32> & Sys.Completion<String,String>)>:
  match caps:
    case Resource.Reader{get}:read_resource(~Permit,~H,capture,get(scope))
    case Resource.UnsupportedReader{}:Task.TDone{(scope,(capture,Sys.BodyError{"Counter unsupported","capture retained"}))}
def reader_body(~Permit:Data,~H:Type,~caps:ReaderOps(Permit,H),scope:H,capture:Array<U32>) -> Task.Task<P.AuditWorkshop,Permit,H & (Array<U32> & Sys.Completion<String,String>)>:
  reader_caps(~Permit,~H,caps,scope,capture)
type QueryLocal is Type:
  QueryReady{target:W.Handle<P.AuditWorkshop>,pack:P.QueryPack}
  QueryDeferred{target:W.Handle<P.AuditWorkshop>,unused:U32 -> U32 & P.QueryPack}
def query_edited(~Permit:Data,~H:Type,target:W.Handle<P.AuditWorkshop>,result:H & Q.GeneralEdit<U32,P.QueryPack>) -> Task.Task<P.AuditWorkshop,Permit,H & (QueryLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,Q.GeneralEdited{pack}):Task.TDone{(scope,(QueryReady{target,pack},Sys.Success{"scalar += 4"}))}
    case (scope,Q.GeneralUnchanged{unused}):Task.TDone{(scope,(QueryDeferred{target,unused},Sys.BodyError{"scalar write refused","capture retained in operation"}))}
def query_value(pack:P.QueryPack,+prior:U32,value:U32) -> U32 & P.QueryPack:(U32.add(value,4),P.update(prior,pack))
def query_read(~Permit:Data,~H:Type,modify:@-Out:Type -> H -> W.Handle<P.AuditWorkshop> -> (U32 -> U32 & Out) -> H & Q.GeneralEdit<U32,Out>,+target:W.Handle<P.AuditWorkshop>,pack:P.QueryPack,result:H & Q.GeneralLookup<U32>) -> Task.Task<P.AuditWorkshop,Permit,H & (QueryLocal & Sys.Completion<String,String>)>:
  match result:
    case (scope,Q.Matched{Some{value}}):query_edited(~Permit,~H,target,modify(P.QueryPack,scope,target,query_value(pack,value)))
    case (scope,_):Task.TDone{(scope,(QueryReady{target,pack},Sys.BodyError{"scalar query missed","capture retained"}))}
def query_caps(~Permit:Data,~H:Type,caps:QueryOps(Unit,H),scope:H,local:QueryLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (QueryLocal & Sys.Completion<String,String>)>:
  match caps local:
    case Q.GeneralWriter{Q.GeneralReader{_,get},modify,_} QueryReady{+target,pack}:query_read(~Permit,~H,modify,target,pack,get(scope,target))
    case _ local:Task.TDone{(scope,(local,Sys.BodyError{"scalar query unsupported","capture retained"}))}
def query_body(~Permit:Data,~H:Type,~caps:QueryOps(Permit,H),scope:H,local:QueryLocal) -> Task.Task<P.AuditWorkshop,Permit,H & (QueryLocal & Sys.Completion<String,String>)>:
  query_caps(~Permit,~H,caps,scope,local)
def writer_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~WriterOps,~writer_kernel)
def reader_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~ReaderOps,~reader_kernel)
def query_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~QueryOps,~query_kernel)
def Writer() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,WriterOps,WriterLocal,String,String,writer_kernel,writer_body>
def Reader() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,ReaderOps,Array<U32>,String,String,reader_kernel,reader_body>
def Query() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,QueryOps,QueryLocal,String,String,query_kernel,query_body>

def WriterBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>,Writer()>
def QueryBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>,Query()>
def ReaderBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>,Reader()>
type Registration is Type:
  Registered{world:World(),writer:WriterBinding(),query:QueryBinding(),reader:ReaderBinding()}
  WriterRefused{world:World(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>,writer:WriterLocal,query:QueryLocal,reader:Array<U32>}
  QueryRefused{world:World(),writer:WriterBinding(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>,query:QueryLocal,reader:Array<U32>}
  ReaderRefused{world:World(),writer:WriterBinding(),query:QueryBinding(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>,reader:Array<U32>}
def reader_registered(writer:WriterBinding(),query:QueryBinding(),result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps> & Sys.Defined<World(),Reader(),Array<U32>>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,reader}):Registered{world,writer,query,Scope.CompiledBinding{compilation,reader}}
    case (compilation,Sys.DefinitionRefused{world,reader}):ReaderRefused{world,writer,query,compilation,reader}
def query_registered(writer:WriterBinding(),reader:Array<U32>,result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps> & Sys.Defined<World(),Query(),QueryLocal>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,query}):reader_registered(writer,Scope.CompiledBinding{compilation,query},Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~ReaderOps,~Array<U32>,~String,~String,~reader_kernel,~reader_body,~L.resources(~P.AuditWorkshop,Author.resources()),reader_compiled(),world,"CapturedCounterReader",reader))
    case (compilation,Sys.DefinitionRefused{world,query}):QueryRefused{world,writer,compilation,query,reader}
def writer_registered(query:QueryLocal,reader:Array<U32>,result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps> & Sys.Defined<World(),Writer(),WriterLocal>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,writer}):query_registered(Scope.CompiledBinding{compilation,writer},reader,Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~QueryOps,~QueryLocal,~String,~String,~query_kernel,~query_body,~L.resources(~P.AuditWorkshop,Author.resources()),query_compiled(),world,"CapturedScalarQuery",query))
    case (compilation,Sys.DefinitionRefused{world,writer}):WriterRefused{world,compilation,writer,query,reader}
def define(world:World(),target:W.Handle<P.AuditWorkshop>) -> Registration:
  writer_registered(QueryReady{target,P.initial_query()},P.initial_resource_capture(),Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body,~L.resources(~P.AuditWorkshop,Author.resources()),writer_compiled(),world,"CounterFieldWriter",WriterLocal{[],[]}))
def WriterNode() -> Type:Leaf.node_type(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~WriterOps,~WriterLocal,~writer_kernel,~writer_body)
def QueryNode() -> Type:Leaf.node_type(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~QueryOps,~QueryLocal,~query_kernel,~query_body)
def ReaderNode() -> Type:Leaf.node_type(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~ReaderOps,~Array<U32>,~reader_kernel,~reader_body)
