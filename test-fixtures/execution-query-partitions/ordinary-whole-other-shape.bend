import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/execution-resource-query-leaf.bend as GeneralLeaf
import ../../src/ecs/execution-resource-query-group.bend as GeneralGroup
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import Base
import ../../src/ecs/execution-generalized-root-application.bend as GeneralRoot
import ../../src/ecs/execution-parallel-root-application.bend as RootApp
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as ResourceAccess
import ../../src/ecs/execution-resource-policy.bend as ResourcePolicy
import ../../src/ecs/execution-resource-program.bend as ResourceProgram
import ../../src/ecs/execution-resource-query-execution.bend as Combined
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/owner-product.bend as Product

import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-reservation-authority.bend as RuntimePermit
import ./schema.bend as S
import ./schema-walk.bend as Walk
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-query-interpreter.bend as Interpret
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-query-preparation.bend as General
import ../../src/ecs/execution-parallel-schedule.bend as Ready

def WC() -> Type:L.columns(~S.SchemaA,S.layout_b())
def LocalStore() -> Type:WC()
def Caps(H:Type) -> Type:Q.GeneralReader<S.SchemaA,H,U32>
def Ops(Permit:Data,H:Type) -> Type:Caps(H)
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~S.layout_b(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Whole{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~query,book)
def program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  builder(Ops,selection(~Permit,~H,~B),book)
type Local is Type:
  Local{values:Array<U32>}
def observed(~H:Type,local:Local,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (Local & Sys.Completion<String,Unit>):
  match result:
    case (scope,Q.SelectedRows{_}):(scope,(local,Sys.Success{Unit{}}))
    case (scope,Q.SelectionRefused{}):(scope,(local,Sys.BodyError{"selection-refused",Unit{}}))
def run_caps(~H:Type,caps:Caps(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Unit>):
  match caps:
    case Q.GeneralReader{query,_}:observed(~H,local,query(scope))
    case Q.UnsupportedReader{}:(scope,(local,Sys.BodyError{"unsupported",Unit{}}))
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,Unit>)>:
  Effect.TDone{run_caps(~H,caps,scope,local)}
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.framework_program(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,~program,~Permit,~token,~H,~B,~builder,book)
def compiled() -> D.Compilation<S.SchemaA,WC(),LocalStore(),Unit,Ops>:
  Build.compile_framework_with_general(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Interpret.provider_dictionary(~S.SchemaA,~WC(),~LocalStore(),~Unit),~Ops,~kernel)
def Compilation() -> Type:D.Compilation<S.SchemaA,WC(),LocalStore(),Unit,Ops>
def Owner() -> Type:Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,kernel,body>
def Evidence() -> Data:Maybe<&2,General.Evidence<S.SchemaA,S.layout_b(),LocalStore(),Unit,Ops,kernel>>
def Bound() -> Type:Binding.Binding<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>>
def Preparation() -> Type:Binding.Preparation<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>>
def Invocation() -> Type:Binding.Invocation<Compilation(),State.Scope<S.SchemaA,LocalStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>,List<&2,Ready.Completed<String,Unit>>>
def define(compilation:Compilation(),world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Local>:
  General.define_with_compilation(~S.SchemaA,~S.layout_b(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,compilation,world,"general-whole",local)
def prepare(compilation:Compilation(),ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:Owner()) -> Preparation():
  General.prepare_with_compilation(~S.SchemaA,~S.layout_b(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,compilation,ids,world,owner)
def invoke(scope:State.Scope<S.SchemaA,LocalStore(),Unit>,binding:Bound()) -> Effect.Task<S.SchemaA,RuntimePermit.Permit,Invocation()>:
  General.invoke_whole(~S.SchemaA,~S.layout_b(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,compiled()),~Scope.no_structural(~Ops(Effect.Granted,State.Scope<S.SchemaA,LocalStore(),Unit>)),scope,binding)

# Existing unlike-shape ordinary consumer: arbitrary affine Array and String
# resources use the same full origin, admitted recipes, and one administrative owner.
def combined_array_view(result:Array<U32> & U32,right:Array<U32>) -> Array<U32> & U32:
  match result:
    case (left,value):(ANode{left,right},value)
def combined_array_refresh(owner:Array<U32>) -> Array<U32> & U32:
  match owner:
    case ALeaf{+value}:(ALeaf{value},value)
    case ANode{left,right}:combined_array_view(combined_array_refresh(left),right)
def combined_string_refresh(owner:String) -> String & U32:(owner,7)
def combined_resources() -> L.Layout:
  L.LayoutPair{L.LayoutLeaf{Array<U32>,U32,combined_array_refresh,"combined-array",ResourcePolicy.Ordinary{}},L.LayoutLeaf{String,U32,combined_string_refresh,"combined-string",ResourcePolicy.Ordinary{}}}
def CombinedColumns() -> Type:Store.Storage<S.SchemaA,S.layout_b()>
def CombinedResources() -> Type:ResourceStore.Storage<S.SchemaA,combined_resources()>
def CombinedWorld() -> Type:W.World<S.SchemaA,WC(),L.resources(~S.SchemaA,combined_resources()),Unit>
def CombinedLeftOps(Permit:Data,H:Type) -> Type:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Writer<H,Array<U32>,U32>>
def CombinedRightOps(Permit:Data,H:Type) -> Type:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>
type CombinedToken is Type:
  CombinedArray{values:Array<U32>}
  CombinedDeferred{transform:Array<U32> -> Array<U32> & Array<U32>}
type CombinedLocal is Type:
  CombinedLocal{token:CombinedToken}
def combined_left_resource(~H:Type,~B:Type,query:Q.GeneralReader<S.SchemaA,H,U32>,result:B & ResourceAccess.Writer<H,Array<U32>,U32>) -> B & CombinedLeftOps(Unit,H):
  match result:
    case (book,write):(book,Cap.Bundle{query,write})
def combined_right_resource(~H:Type,~B:Type,query:Q.GeneralReader<S.SchemaA,H,U32>,result:B & ResourceAccess.Reader<H,U32>) -> B & CombinedRightOps(Unit,H):
  match result:
    case (book,read):(book,Cap.Bundle{query,read})
def combined_left_query(~H:Type,~B:Type,~resource:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),result:B & Q.GeneralReader<S.SchemaA,H,U32>) -> B & CombinedLeftOps(Unit,H):
  match result:
    case (book,query):combined_left_resource(~H,~B,query,Build.general_resource_write(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InLeft{L.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~resource,book))
def combined_right_query(~H:Type,~B:Type,~resource:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),query:Q.GeneralReader<S.SchemaA,H,U32>,book:B,own:Bool) -> B & CombinedRightOps(Unit,H):
  match own:
    case True{}:combined_right_resource(~H,~B,query,Build.general_resource_read(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InLeft{L.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~resource,book))
    case False{}:combined_right_resource(~H,~B,query,Build.general_resource_read(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InRight{L.AtLeaf{}},~{==},~ResourceStore.Sparse{},~{==},~resource,book))
def combined_right_selected(~own:Bool,~H:Type,~B:Type,~resource:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),result:B & Q.GeneralReader<S.SchemaA,H,U32>) -> B & CombinedRightOps(Unit,H):
  match result:
    case (book,query):combined_right_query(~H,~B,~resource,query,book,own)
def combined_left_selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~q:Build.Query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),book:B) -> B & CombinedLeftOps(Permit,H):
  combined_left_query(~H,~B,~rw,Build.general_query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~S.layout_b(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~q,book))
def combined_right_selection(~own:Bool,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~q:Build.Query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),book:B) -> B & CombinedRightOps(Permit,H):
  combined_right_selected(~own,~H,~B,~rr,Build.general_query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~S.layout_b(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~q,book))
def combined_left_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~H,~B),book:B) -> B & CombinedLeftOps(Permit,H):
  builder(CombinedLeftOps,combined_left_selection(~Permit,~H,~B),book)
def combined_right_program(~own:Bool,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~H,~B),book:B) -> B & CombinedRightOps(Permit,H):
  builder(CombinedRightOps,combined_right_selection(~own,~Permit,~H,~B),book)
def combined_left_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~H,~B),book:B) -> B & CombinedLeftOps(Permit,H):
  Build.framework_program(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedLeftOps,~combined_left_program,~Permit,~token,~H,~B,~builder,book)
def combined_right_kernel(~own:Bool,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~H,~B),book:B) -> B & CombinedRightOps(Permit,H):
  Build.framework_program(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedRightOps,~combined_right_program(~own),~Permit,~token,~H,~B,~builder,book)
def combined_left_observed(~H:Type,local:CombinedLocal,result:H & ResourceStore.Lookup<U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Viewed{view,_}):(scope,(local,Sys.BodyError{"retained-left",Some{view}}))
    case (scope,ResourceStore.LookupRefused{}):(scope,(local,Sys.BodyError{"read-refused",None{}}))
def combined_left_updated(~H:Type,get:H -> H & ResourceStore.Lookup<U32>,result:H & ResourceStore.Edit<Array<U32>,Array<U32>>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Edited{values}):combined_left_observed(~H,CombinedLocal{CombinedArray{values}},get(scope))
    case (scope,ResourceStore.Unchanged{unused}):(scope,(CombinedLocal{CombinedDeferred{unused}},Sys.BodyError{"write-refused",None{}}))
def combined_left_write(~H:Type,write:ResourceAccess.Writer<H,Array<U32>,U32>,scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match write local:
    case ResourceAccess.Writer{ResourceAccess.Reader{get},own,_} CombinedLocal{CombinedArray{values}}:combined_left_updated(~H,get,own(Array<U32>,scope,(owner => (ALeaf{42},values))))
    case write local:(scope,(local,Sys.BodyError{"deferred",None{}}))
def combined_left_queried(~H:Type,write:ResourceAccess.Writer<H,Array<U32>,U32>,local:CombinedLocal,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,_):combined_left_write(~H,write,scope,local)
def combined_left_caps(~H:Type,caps:CombinedLeftOps(Unit,H),scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match caps:
    case Cap.Bundle{Q.GeneralReader{query,_},write}:combined_left_queried(~H,write,local,query(scope))
    case caps:(scope,(local,Sys.BodyError{"unsupported-query",None{}}))
def combined_left_body(~Permit:Data,~H:Type,~caps:CombinedLeftOps(Permit,H),scope:H,local:CombinedLocal) -> Effect.Task<S.SchemaA,Permit,H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>)>:
  Effect.TDone{combined_left_caps(~H,caps,scope,local)}
def combined_right_observed(~H:Type,local:CombinedLocal,result:H & ResourceStore.Lookup<U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Viewed{view,_}):(scope,(local,Sys.Success{Some{view}}))
    case (scope,ResourceStore.LookupRefused{}):(scope,(local,Sys.BodyError{"read-refused",None{}}))
def combined_right_queried(~H:Type,read:ResourceAccess.Reader<H,U32>,local:CombinedLocal,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match read result:
    case ResourceAccess.Reader{get}, (scope,_):combined_right_observed(~H,local,get(scope))
    case ResourceAccess.UnsupportedReader{}, (scope,_):(scope,(local,Sys.BodyError{"unsupported-read",None{}}))
def combined_right_caps(~H:Type,caps:CombinedRightOps(Unit,H),scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match caps:
    case Cap.Bundle{Q.GeneralReader{query,_},read}:combined_right_queried(~H,read,local,query(scope))
    case caps:(scope,(local,Sys.BodyError{"unsupported-query",None{}}))
def combined_right_body(~Permit:Data,~H:Type,~caps:CombinedRightOps(Permit,H),scope:H,local:CombinedLocal) -> Effect.Task<S.SchemaA,Permit,H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>)>:
  Effect.TDone{combined_right_caps(~H,caps,scope,local)}
# Concrete full-shape specialization; the package owns its actual registered locals.
def combined_left_compiled() -> D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>:
  ResourceProgram.compile_framework(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedLeftOps,~combined_left_kernel)
def combined_right_compiled(~own:Bool) -> D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>:
  ResourceProgram.compile_framework(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedRightOps,~combined_right_kernel(own))
type CombinedRegistration<-own:Bool> is Type:
  CombinedRegistered{world:CombinedWorld(),left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,right:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>}
  CombinedLeftRejected{world:CombinedWorld(),compilation:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,left:CombinedLocal,right:CombinedLocal}
  CombinedRightRejected{world:CombinedWorld(),left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,compilation:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,right:CombinedLocal}
def combined_right_registered(~own:Bool,left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,result:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps> & Sys.Defined<CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,CombinedLocal>) -> CombinedRegistration<own>:
  match result:
    case (compilation,Sys.Defined{world,system}):CombinedRegistered{world,left,Scope.CompiledBinding{compilation,system}}
    case (compilation,Sys.DefinitionRefused{world,local}):CombinedRightRejected{world,left,compilation,local}
def combined_left_registered(~own:Bool,right:CombinedLocal,result:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps> & Sys.Defined<CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,CombinedLocal>) -> CombinedRegistration<own>:
  match result:
    case (compilation,Sys.Defined{world,system}):combined_right_registered(~own,Scope.CompiledBinding{compilation,system},Task.define_with_compilation(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Unit,~CombinedRightOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_right_kernel(own),~combined_right_body,~L.resources(~S.SchemaA,combined_resources()),combined_right_compiled(~own),world,"combined-right",right))
    case (compilation,Sys.DefinitionRefused{world,local}):CombinedLeftRejected{world,compilation,local,right}
def combined_register(~own:Bool,world:CombinedWorld(),left:CombinedLocal,right:CombinedLocal) -> CombinedRegistration<own>:
  combined_left_registered(~own,right,Task.define_with_compilation(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Unit,~CombinedLeftOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_left_kernel,~combined_left_body,~L.resources(~S.SchemaA,combined_resources()),combined_left_compiled(),world,"combined-left",left))
type CombinedPipeline<-own:Bool> is Type:
  CombinedExecuted{result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,String,Maybe<&2,U32>>}
  CombinedRegistrationRefused{inventory:CombinedRegistration<own>}
  CombinedPriorInventory{displaced:List<&1,Schema.displacements(~S.SchemaA,S.layout_b())>,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,String,Maybe<&2,U32>>}
def combined_executed(~own:Bool,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  IO.pure(CombinedPipeline<own>,CombinedExecuted{result})
def combined_registered(~own:Bool,registration:CombinedRegistration<own>) -> IO(CombinedPipeline<own>):
  match registration:
    case CombinedRegistered{world,left,right}:IO.bind(Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,String,Maybe<&2,U32>>,CombinedPipeline<own>,Tree.run_generalized(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,[1,2],world,Tree.GeneralizedPair{Tree.compile_generalized_leaf(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body,~combined_left_compiled(),left),Tree.compile_generalized_leaf(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body,~combined_right_compiled(~own),right)}),result => combined_executed(~own,result))
    case inventory:IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{inventory})

def combined_serial_registered(world:CombinedWorld(),left:CombinedLocal,right:CombinedLocal) -> IO(CombinedPipeline<True{}>):
  combined_registered(~True{},combined_register(~True{},world,left,right))
def combined_native_registered(world:CombinedWorld(),left:CombinedLocal,right:CombinedLocal) -> IO(CombinedPipeline<False{}>):
  combined_registered(~False{},combined_register(~False{},world,left,right))
def CombinedLeftNode() -> Type:GeneralLeaf.node_type(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body)
def CombinedRightNode(~own:Bool) -> Type:GeneralLeaf.node_type(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body)
def combined_restore_left(node:CombinedLeftNode()) -> Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>:GeneralLeaf.restore_node(D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Admission.Evidence<S.SchemaA,S.layout_b(),combined_resources(),CombinedColumns(),CombinedResources(),CombinedLeftOps,combined_left_kernel>,Prep.Permit<S.SchemaA,WC()>,node)
def combined_restore_right(~own:Bool,node:CombinedRightNode(~own)) -> Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>:GeneralLeaf.restore_node(D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,Admission.Evidence<S.SchemaA,S.layout_b(),combined_resources(),CombinedColumns(),CombinedResources(),CombinedRightOps,combined_right_kernel(own)>,Prep.Permit<S.SchemaA,WC()>,node)
def combined_restore_retained(~own:Bool,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  combined_executed(~own,GeneralGroup.restore_retained(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,CombinedLeftNode(),CombinedRightNode(~own),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,combined_restore_left,combined_restore_right(~own),result))
def combined_retained_group(~own:Bool,world:CombinedWorld(),left:CombinedLeftNode(),right:CombinedRightNode(~own)) -> IO(Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>):
  GeneralGroup.run_retained(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,CombinedLeftNode(),CombinedRightNode(~own),[1,2],world,GeneralLeaf.from_retained(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedLeftOps,combined_left_compiled()),left),GeneralLeaf.from_retained(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedRightOps,combined_right_compiled(~own)),right))
def combined_prior_restored(~own:Bool,displaced:List<&1,Schema.displacements(~S.SchemaA,S.layout_b())>,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  IO.pure(CombinedPipeline<own>,CombinedPriorInventory{displaced,result})
def combined_repeat_finished(~own:Bool,prior:List<&2,Ready.Completed<String,Maybe<&2,U32>>>,priorMoved:List<&1,Schema.displacements(~S.SchemaA,S.layout_b())>,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case Combined.Returned{world,nodes,status,moved}:combined_restore_retained(~own,Combined.Returned{world,nodes,List.append(&2,Ready.Completed<String,Maybe<&2,U32>>,prior,status),List.append(&1,Schema.displacements(~S.SchemaA,S.layout_b()),priorMoved,moved)})
    case Combined.AdmissionRefused{world,nodes,status}:combined_prior_restored(~own,priorMoved,GeneralGroup.restore_retained(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,CombinedLeftNode(),CombinedRightNode(~own),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,combined_restore_left,combined_restore_right(~own),Combined.AdmissionRefused{world,nodes,List.append(&2,Ready.Completed<String,Maybe<&2,U32>>,prior,status)}))
    case Combined.CutInventoryRefused{admin,inventory,nodes,status,moved}:combined_restore_retained(~own,Combined.CutInventoryRefused{admin,inventory,nodes,List.append(&2,Ready.Completed<String,Maybe<&2,U32>>,prior,status),List.append(&1,Schema.displacements(~S.SchemaA,S.layout_b()),priorMoved,moved)})
    case Combined.JoinInventoryRefused{admin,inventory,nodes,status,moved}:combined_restore_retained(~own,Combined.JoinInventoryRefused{admin,inventory,nodes,List.append(&2,Ready.Completed<String,Maybe<&2,U32>>,prior,status),List.append(&1,Schema.displacements(~S.SchemaA,S.layout_b()),priorMoved,moved)})
    case Combined.NestedInventoryRefused{Inventory,admin,inventory,nodes,status,moved}:combined_restore_retained(~own,Combined.NestedInventoryRefused{Inventory,admin,inventory,nodes,List.append(&2,Ready.Completed<String,Maybe<&2,U32>>,prior,status),List.append(&1,Schema.displacements(~S.SchemaA,S.layout_b()),priorMoved,moved)})
def combined_extra_live(result:CombinedWorld() & W.Reservation<S.SchemaA>) -> CombinedWorld():
  match result:
    case (world,W.Reserved{handle}):W.discard_status(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,W.activate(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):world
def combined_repeat_first(~own:Bool,result:Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case Combined.Returned{world,Product.Owner{left,right},status,moved}:IO.bind(Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>,CombinedPipeline<own>,combined_retained_group(~own,combined_extra_live(W.reserve_id(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,world)),left,right),result => combined_repeat_finished(~own,status,moved,result))
    case result:combined_restore_retained(~own,result)
def combined_repeat_registered(~own:Bool,registration:CombinedRegistration<own>) -> IO(CombinedPipeline<own>):
  match registration:
    case CombinedRegistered{world,left,right}:IO.bind(Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>,String,Maybe<&2,U32>>,CombinedPipeline<own>,combined_retained_group(~own,world,GeneralLeaf.retain(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body,left),GeneralLeaf.retain(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body,right)),result => combined_repeat_first(~own,result))
    case inventory:IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{inventory})

def RootNodes(~own:Bool) -> Type:Product.Owner<CombinedLeftNode(),CombinedRightNode(~own)>
def RootGuardOps(Permit:Data,H:Type) -> Type:Unit
def root_guard_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~WC(),~L.resources(~S.SchemaA,combined_resources()),~Permit,~H,~B),book:B) -> B & RootGuardOps(Permit,H):(book,Unit{})
def root_guard_result(local:U32,error:Bool) -> Sys.Completion<String,Bool>:
  match error:
    case True{}:Sys.BodyError{"root-guard-error",False{}}
    case False{}:Sys.Success{Bool.not(U32.is_eq(local,1))}
def root_guard_updated(~Permit:Data,~H:Type,scope:H,+local:U32) -> Effect.Task<S.SchemaA,Permit,H & (U32 & Sys.Completion<String,Bool>)>:
  Effect.TDone{(scope,(U32.add(local,1),root_guard_result(local,U32.is_eq(local,4))))}
def root_guard_body(~Permit:Data,~H:Type,~caps:RootGuardOps(Permit,H),scope:H,local:U32) -> Effect.Task<S.SchemaA,Permit,H & (U32 & Sys.Completion<String,Bool>)>:
  root_guard_updated(~Permit,~H,scope,local)
def RootGuard() -> Type:Sys.Owner<S.SchemaA,WC(),WC(),L.resources(~S.SchemaA,combined_resources()),Unit,RootGuardOps,U32,String,Bool,root_guard_kernel,root_guard_body>
def RootGuardCompilation() -> Type:D.Compilation<S.SchemaA,WC(),WC(),L.resources(~S.SchemaA,combined_resources()),RootGuardOps>
def root_guard_construction() -> RootGuardCompilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~WC(),~L.resources(~S.SchemaA,combined_resources()),~RootGuardOps,~root_guard_kernel)
def RetainedRootGuard() -> Type:Scope.CompiledBinding<RootGuardCompilation(),RootGuard()>
def root_guard_dispatch() -> Conditions.Dispatch(~CombinedWorld(),~RetainedRootGuard(),~String):Conditions.retained_leaf_dispatch(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,~RootGuardOps,~U32,~String,~root_guard_kernel,~root_guard_body,~root_guard_construction())
def RootApplication(~own:Bool) -> Type:RootApp.Scheduled<App.State<GeneralRoot.Storage<S.SchemaA,S.layout_b(),combined_resources(),Unit>,RootNodes(~own),RetainedRootGuard(),U32>>
def root_dispatch(~own:Bool,nodes:RootNodes(~own),world:CombinedWorld(),ids:List<&2,U32>) -> IO(Combined.RunResult<S.SchemaA,S.layout_b(),combined_resources(),Unit,RootNodes(~own),String,Maybe<&2,U32>>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,CombinedLeftNode(),CombinedRightNode(~own),ids,world,Tree.GeneralizedPair{Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body,~combined_left_compiled(),left),Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body,~combined_right_compiled(~own),right)})
def root_publish(~own:Bool,ids:List<&2,U32>,world:CombinedWorld(),nodes:RootNodes(~own)) -> CombinedWorld() & (RootNodes(~own) & List<&2,U32>):(world,(nodes,[]))
def root_handle(count:U32,error:String) -> U32 & Exec.Handling:(U32.add(count,1),Exec.Continue{})
def root_available(_:String) -> Bool:True{}
def root_run(~own:Bool,app:RootApplication(~own)) -> IO(RootApplication(~own) & App.Report<String,Maybe<&2,U32>>):
  GeneralRoot.run(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~RootNodes(~own),~RetainedRootGuard(),~U32,~String,~Maybe<&2,U32>,~root_dispatch(~own),~root_guard_dispatch(),~root_handle,~root_publish(~own),app)
def root_output(value:Maybe<&2,U32>) -> String:
  match value:
    case Some{value}:U32.show(value)
    case None{}:"none"
def root_event(value:Exec.Observation<String,Maybe<&2,U32>>) -> String:
  match value:
    case Exec.Ran{id,value}:"ran:" ++ U32.show(id) ++ ":" ++ root_output(value)
    case Exec.BodyFailed{id,error,value}:"body-error:" ++ U32.show(id) ++ ":" ++ error ++ ":" ++ root_output(value)
    case Exec.Skipped{id}:"disabled:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"guard-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"guard-refused:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"body-refused:" ++ U32.show(id)
def root_report(report:App.Report<String,Maybe<&2,U32>>) -> String:
  match report:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<String,Maybe<&2,U32>>,root_event,events)
    case App.Stopped{error,_}:"stopped:" ++ error
    case App.Invalid{_}:"invalid"
def root_guard_text(guard:RootGuard()) -> String:
  match guard:
    case Sys.Owner{_,id,_,_,cursor,local}:"guard=" ++ U32.show(id) ++ "/" ++ U32.show(local) ++ "/" ++ Tick.cursor_show(cursor)
def root_restored(~own:Bool,storage:GeneralRoot.Storage<S.SchemaA,S.layout_b(),combined_resources(),Unit>,nodes:RootNodes(~own)) -> IO(CombinedPipeline<own>):
  match storage:
    case GeneralRoot.Present{world,moved}:combined_restore_retained(~own,Combined.Returned{world,nodes,[],moved})
    case GeneralRoot.CutRefused{admin,inventory,moved}:combined_restore_retained(~own,Combined.CutInventoryRefused{admin,inventory,nodes,[],moved})
    case GeneralRoot.JoinRefused{admin,inventory,moved}:combined_restore_retained(~own,Combined.JoinInventoryRefused{admin,inventory,nodes,[],moved})
    case GeneralRoot.NestedRefused{Inventory,admin,inventory,moved}:combined_restore_retained(~own,Combined.NestedInventoryRefused{Inventory,admin,inventory,nodes,[],moved})
def root_final(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (RootApp.Scheduled{App.State{storage,nodes,Scope.CompiledBinding{_,guard},handler,_},_,_,_,_},report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-final=" ++ root_report(report) ++ "|" ++ root_guard_text(guard) ++ "|handler=" ++ U32.show(handler)),_ => root_restored(~own,storage,nodes))
def root_third(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (app,report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-second=" ++ root_report(report)),_ => IO.bind(RootApplication(~own) & App.Report<String,Maybe<&2,U32>>,CombinedPipeline<own>,root_run(~own,app),root_final(~own)))
def root_changed(~own:Bool,app:RootApplication(~own)) -> RootApplication(~own):
  match app:
    case RootApp.Scheduled{App.State{GeneralRoot.Present{world,moved},nodes,guard,handler,stateBindings},plan,bindings,rules,deferred}:RootApp.Scheduled{App.State{GeneralRoot.Present{combined_extra_live(W.reserve_id(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,world)),moved},nodes,guard,handler,stateBindings},plan,bindings,rules,deferred}
    case app:app
def root_second(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (app,report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-first=" ++ root_report(report)),_ => IO.bind(RootApplication(~own) & App.Report<String,Maybe<&2,U32>>,CombinedPipeline<own>,root_run(~own,root_changed(~own,app)),root_third(~own)))
def root_guard_defined(~own:Bool,left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,right:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>,result:RootGuardCompilation() & Sys.Defined<CombinedWorld(),RootGuard(),U32>) -> IO(CombinedPipeline<own>):
  match result:
    case (compilation,Sys.Defined{world,guard}):IO.bind(RootApplication(~own) & App.Report<String,Maybe<&2,U32>>,CombinedPipeline<own>,root_run(~own,GeneralRoot.build(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~RootNodes(~own),~RetainedRootGuard(),~U32,~String,~root_guard_dispatch(),~root_available,world,Tree.generalized_pair_facts(CombinedLeftNode(),CombinedRightNode(~own),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedLeftOps,~CombinedLocal,~combined_left_kernel,~combined_left_body,left),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~String,~Maybe<&2,U32>,~CombinedRightOps,~CombinedLocal,~combined_right_kernel(own),~combined_right_body,right)),Conditions.compile_retained_leaf(~String,~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,~RootGuardOps,~U32,~root_guard_kernel,~root_guard_body,~root_guard_construction(),Scope.CompiledBinding{compilation,guard}),0,[Plan.Edge{1,2}],[App.Binding{1,3},App.Binding{2,3}])),root_second(~own))
    case (_,Sys.DefinitionRefused{world,_}):IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{CombinedRegistered{world,left,right}})
def combined_root_registered(~own:Bool,registration:CombinedRegistration<own>) -> IO(CombinedPipeline<own>):
  match registration:
    case CombinedRegistered{world,left,right}:root_guard_defined(~own,left,right,Task.define_with_compilation(~S.SchemaA,~WC(),~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,~RootGuardOps,~U32,~String,~Bool,~root_guard_kernel,~root_guard_body,~L.resources(~S.SchemaA,combined_resources()),root_guard_construction(),world,"root-guard",0))
    case inventory:IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{inventory})
