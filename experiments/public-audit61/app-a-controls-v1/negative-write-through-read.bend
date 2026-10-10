import Base
import ./bundle.bend as B
import ./resources.bend as R
import ./component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def Ops(H:Type) -> Type:
  Cap.Read<H,U32>
def declaration() -> Query.Declaration<B.AuditWorkshop,Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,Ops(Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>)>:
  Query.read(~B.AuditWorkshop,~U32,~B.Store,~R.Resources(),~U32,~Col.Column<B.AuditWorkshop,Array<U32>>,~U32,~B.ScalarToken,~Component.identity(),~B.project_scalar,~B.take_scalar,~B.put_scalar)
# Actual read-only ordinary Ops boundary, still abstract over affine H.
def rejected(~H:Type,~cap:Ops(H),unit:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Cap.set(~H,~U32,~U32,~cap,owner,15),(T.Success{},Unit{}))
def main() -> Unit:
  Unit{}
