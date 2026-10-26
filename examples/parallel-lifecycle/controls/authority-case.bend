import Base
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-system.bend as Sys

type Schema is Data:
  Schema{}
def Ops(H:Type) -> Type:Unit
def declaration(~WC:Type,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC,~Unit,~Unit,~H,~B),book:B) -> B & Ops(H):
  (book,Unit{})
def body(~H:Type,~cap:Unit,owner:H,local:Unit) -> H & (Unit & Sys.Completion<String,Unit>):
  (owner,(local,Sys.Success{Unit{}}))
def Owner(~WC:Type) -> Type:Sys.Owner<Schema,WC,Unit,Unit,Unit,Ops,Unit,String,Unit,declaration(~WC),body>
