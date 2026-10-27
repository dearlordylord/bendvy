import Base
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
def Ops(H:Type) -> Type:Q.GeneralReader<S.SchemaA,H,U32>
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  Build.general_query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Whole{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~query,book)
def program(~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)
type Local is Type:
  Local{values:Array<U32>}
def observed(~H:Type,local:Local,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (Local & Sys.Completion<String,Unit>):
  match result:
    case (scope,Q.SelectedRows{_}):(scope,(local,Sys.Success{Unit{}}))
    case (scope,Q.SelectionRefused{}):(scope,(local,Sys.BodyError{"selection-refused",Unit{}}))
def run_caps(~H:Type,caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Unit>):
  match caps:
    case Q.GeneralReader{query,_}:observed(~H,local,query(scope))
    case Q.UnsupportedReader{}:(scope,(local,Sys.BodyError{"unsupported",Unit{}}))
def body(~H:Type,~caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Unit>):
  run_caps(~H,caps,scope,local)
def compiled() -> D.Compilation<S.SchemaA,WC(),LocalStore(),Unit,Ops>:
  Build.compile_with_general(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Interpret.provider_dictionary(~S.SchemaA,~WC(),~LocalStore(),~Unit),~Ops,~program)
def define(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,Local>:
  General.define(~S.SchemaA,~S.layout_a(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~program,~body,world,"general-whole",local)
def prepare(ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>) -> General.Preparation<W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,General.Evidence<S.SchemaA,S.layout_a(),LocalStore(),Unit,Ops,program>,S.SchemaA,WC()>:
  General.prepare(~S.SchemaA,~S.layout_a(),~LocalStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~program,~body,ids,world,owner)
def invoke(scope:State.Scope<S.SchemaA,LocalStore(),Unit>,binding:General.Binding<W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,General.Evidence<S.SchemaA,S.layout_a(),LocalStore(),Unit,Ops,program>,S.SchemaA,WC()>) -> General.Invocation<State.Scope<S.SchemaA,LocalStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,General.Evidence<S.SchemaA,S.layout_a(),LocalStore(),Unit,Ops,program>,S.SchemaA,WC(),List<&2,Ready.Completed<String,Unit>>>:
  General.invoke_whole(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Unit,~program,~body,scope,binding)
