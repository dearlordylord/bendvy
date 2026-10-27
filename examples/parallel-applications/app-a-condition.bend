import Base
import ./app-a-systems.bend as Systems
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec

def Resources() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def Ops(Permit:Data,H:Type) -> Type:Unit
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Systems.Columns(),~Systems.Columns(),~Resources(),~Permit,~H,~B),book:B) -> B & Unit:(book,Unit{})
def body(~Permit:Data,~H:Type,~caps:Unit,scope:H,runs:U32) -> Task.Task<P.AuditWorkshop,Permit,H & (U32 & Sys.Completion<String,Bool>)>:
  +count=runs
  Task.TDone{(scope,(U32.add(count,1),Sys.Success{Bool.not(U32.is_eq(count,1))}))}
def Owner() -> Type:Sys.Owner<P.AuditWorkshop,Systems.Columns(),Systems.Columns(),Resources(),Unit,Ops,U32,String,Bool,kernel,body>
def define(world:Systems.World()) -> Sys.Defined<Systems.World(),Owner(),U32>:
  Register.define_framework(~P.AuditWorkshop,~Systems.Columns(),~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~String,~Bool,~kernel,~body,~Resources(),world,"CapturedQueryEnabled",0)
def dispatch() -> Owner() -> Systems.World() -> U32 -> IO(Owner() & (Systems.World() & Exec.Invocation<String,Bool>)):
  Conditions.leaf_dispatch(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~String,~kernel,~body)
def registry(owner:Owner()) -> Conditions.Registry<Systems.World(),Owner(),String,dispatch()>:
  Conditions.compile_leaf(~String,~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~kernel,~body,owner)
