import Base
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/execution-reservation-task.bend as Effect

type Schema is Data:
  Schema{}
def Ops(Permit:Data,H:Type) -> Type:Unit
def declaration(~WC:Type,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC,~Unit,~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  (book,Unit{})
def program(~WC:Type,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC,~Unit,~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.framework_program(~Schema,~WC,~Unit,~Unit,~Ops,~declaration(~WC),~Permit,~token,~H,~B,~builder,book)
def body(~Permit:Data,~H:Type,~cap:Unit,owner:H,local:Unit) -> Effect.Task<Schema,Permit,H & (Unit & Sys.Completion<String,Unit>)>:
  Effect.TDone{(owner,(local,Sys.Success{Unit{}}))}
def Owner(~WC:Type) -> Type:Sys.Owner<Schema,WC,Unit,Unit,Unit,Ops,Unit,String,Unit,program(~WC),body>
