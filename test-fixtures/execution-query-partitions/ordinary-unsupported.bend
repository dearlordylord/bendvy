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

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def LocalStore() -> Type:Store.Storage<S.SchemaA,S.layout_a()>
def Ops(H:Type) -> Type:Q.GeneralReader<S.SchemaA,H,U32>
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  Build.general_query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~query,book)
def program(~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)
type Local is Type:
  Local{values:Array<U32>}
def body(~H:Type,~caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Unit>):
  match local:
    case Local{values}:(scope,(Local{Array.set(U32,values,0,999)},Sys.BodyError{"must-not-enter",Unit{}}))
def compiled() -> D.Compilation<S.SchemaA,WC(),LocalStore(),Unit,Ops>:
  Build.compile(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,~program)
def define(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,Local>:
  Task.define(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Unit,~Ops,~Local,~String,~Unit,~program,~body,~Unit,world,"unsupported-general",local)
