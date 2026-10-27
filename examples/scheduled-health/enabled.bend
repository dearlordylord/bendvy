import Base
import ./schema.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-parallel-scope.bend as Scope

# The original application condition is always enabled, and is still invoked
# through the condition kernel rather than used as an application-side branch.
def Ops(Permit:Data,H:Type) -> Type:Unit
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~D.Columns(),~D.Resources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):(book,Unit{})
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Unit) -> Task.Task<D.Schema,Permit,H & (Unit & Sys.Completion<String,Bool>)>:
  Task.TDone{(scope,(local,Sys.Success{True{}}))}
def Owner() -> Type:Sys.Owner<D.Schema,D.Columns(),D.Columns(),D.Resources(),Unit,Ops,Unit,String,Bool,kernel,body>
def Compilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),D.Columns(),D.Resources(),Ops>
def construction() -> Compilation():Build.compile_framework(~D.Schema,~D.Columns(),~D.Columns(),~D.Resources(),~Ops,~kernel)
def Binding() -> Type:Scope.CompiledBinding<Compilation(),Owner()>
def handle(local:Unit,_:String) -> Unit & Exec.Handling:(local,Exec.Continue{})
def available(_:String) -> Bool:True{}
