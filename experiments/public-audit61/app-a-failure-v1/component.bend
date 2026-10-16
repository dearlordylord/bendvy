import Base
import bundle.bend as B
import resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def identity() -> Identity.Declaration<B.AuditWorkshop,U32>:
  Identity.component(~B.AuditWorkshop,~U32,"scalar")
def Ops(H:Type) -> Type:
  Cap.Write<H,U32,U32>
def declaration() -> Query.Declaration<B.AuditWorkshop,Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,Ops(Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>)>:
  Query.write(~B.AuditWorkshop,~U32,~B.Store,~R.Resources(),~U32,~Col.Column<B.AuditWorkshop,Array<U32>>,~U32,~B.ScalarToken,~identity(),~B.project_scalar,~B.take_scalar,~B.put_scalar)
def observed(~H:Type,~cap:Ops(H),result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,C.Found{value}):(Cap.set(~H,~U32,~U32,~cap,owner,(value+4:U32)),(T.Success{},Unit{}))
    case (owner,C.ComponentAbsent{}):(owner,(T.Failure{Unit{}},Unit{}))
    case (owner,C.MissingEntity{}):(owner,(T.Failure{Unit{}},Unit{}))
def body(~H:Type,~cap:Ops(H),unit:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  observed(~H,~cap,Cap.get(~H,~U32,~U32,~cap,owner))
