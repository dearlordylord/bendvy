import Base
import ./body.bend as B
import ./schema.bend as S
import ./payload.bend as P
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
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf

def C() -> Type:QueryStore.owner(~S.Workshop,S.components(),QueryStore.Sparse{})
def R() -> Type:ResourceStore.owner(~S.Workshop,S.resources(),ResourceStore.Sparse{})
def Ops(Permit:Data,H:Type) -> Type:Q.GeneralReader<S.Workshop,H,P.Tree>
def any(_:Maybe<&2,P.Tree>) -> Bool:True{}
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.Workshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~S.Workshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~S.Workshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~S.Workshop,~C(),~R(),~H,~B),~q:Build.Query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~H,~B),~life:Build.Lifecycle(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~S.components(),~L.AtLeaf{},~{==},~{==},~QueryStore.Sparse{},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~q,book)
def program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):builder(Ops,selection(~Permit,~H,~B),book)
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):Build.framework_program(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~program,~Permit,~token,~H,~B,~builder,book)


def view(value:Q.GeneralRow<S.Workshop,P.Tree>) -> String:
  match value:
    case Q.GeneralRow{_,Some{tree}}:P.text(tree)
    case _:"Absent"
def selected(~Permit:Data,~H:Type,result:H & Q.GeneralReport<S.Workshop,P.Tree>) -> Task.Task<S.Workshop,Permit,H & (Unit & Sys.Completion<B.Error,String>)>:
  match result:
    case (scope,Q.SelectedRows{rows}):Task.TDone{(scope,(Unit{},Sys.Success{List.show(&2,Q.GeneralRow<S.Workshop,P.Tree>,view,rows)}))}
    case (scope,_):Task.TDone{(scope,(Unit{},Sys.BodyError{B.AuditMissing{},"audit refused"}))}
def body_caps(~Permit:Data,~H:Type,caps:Ops(Unit,H),scope:H) -> Task.Task<S.Workshop,Permit,H & (Unit & Sys.Completion<B.Error,String>)>:
  match caps:
    case Q.GeneralReader{query,_}:selected(~Permit,~H,query(scope))
    case _:Task.TDone{(scope,(Unit{},Sys.BodyError{B.AuditMissing{},"audit unsupported"}))}
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,_:Unit) -> Task.Task<S.Workshop,Permit,H & (Unit & Sys.Completion<B.Error,String>)>:body_caps(~Permit,~H,caps,scope)
def compiled() -> Decl.Compilation<S.Workshop,S.Store(~S.Workshop),C(),R(),Ops>:Program.compile_framework(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~kernel)
def Owner() -> Type:Sys.Owner<S.Workshop,S.Store(~S.Workshop),C(),R(),Unit,Ops,Unit,B.Error,String,kernel,body>
def Node() -> Type:Leaf.node_type(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Error,~String,~Ops,~Unit,~kernel,~body)
