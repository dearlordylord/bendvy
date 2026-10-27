import Base
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-reservation-authority.bend as RuntimePermit
import ./schema.bend as S
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

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def LocalStore() -> Type:WC()
def Caps(H:Type) -> Type:Q.GeneralReader<S.SchemaA,H,U32>
def Ops(Permit:Data,H:Type) -> Type:Caps(H)
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Whole{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~query,book)
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
def Evidence() -> Data:Maybe<&2,General.Evidence<S.SchemaA,S.layout_a(),LocalStore(),Unit,Ops,kernel>>
def Bound() -> Type:Binding.Binding<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>>
def Preparation() -> Type:Binding.Preparation<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>>
def Invocation() -> Type:Binding.Invocation<Compilation(),State.Scope<S.SchemaA,LocalStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Evidence(),Prep.Permit<S.SchemaA,WC()>,List<&2,Ready.Completed<String,Unit>>>
def define(compilation:Compilation(),world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,Owner(),Local>:
  General.define_with_compilation(~S.SchemaA,~S.layout_a(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,compilation,world,"general-whole",local)
def prepare(compilation:Compilation(),ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:Owner()) -> Preparation():
  General.prepare_with_compilation(~S.SchemaA,~S.layout_a(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,compilation,ids,world,owner)
def invoke(scope:State.Scope<S.SchemaA,LocalStore(),Unit>,binding:Bound()) -> Effect.Task<S.SchemaA,RuntimePermit.Permit,Invocation()>:
  General.invoke_whole(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~kernel,~body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,compiled()),~Scope.no_structural(~Ops(Effect.Granted,State.Scope<S.SchemaA,LocalStore(),Unit>)),scope,binding)
