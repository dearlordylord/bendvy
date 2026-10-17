import Base
import capture.bend as P
import ../../../src/ecs/ordinary-capture-query.bend as O
import bundle.bend as B
import resources.bend as R
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/transaction.bend as T
def identity() -> Identity.Declaration<B.AuditWorkshop,U32>:
  Identity.component(~B.AuditWorkshop,~U32,"scalar")
def Ops(H:Type) -> Type:
  Cap.Write<H,U32,U32>
def declaration() -> Query.Declaration<B.AuditWorkshop,Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),Nat>,Ops(Q.Frame<B.AuditWorkshop,B.Store,R.Resources(),Nat>)>:
  Query.write(~B.AuditWorkshop,~U32,~B.Store,~R.Resources(),~Nat,~Col.Column<B.AuditWorkshop,Array<U32>>,~U32,~B.ScalarToken,~identity(),~B.project_scalar,~B.take_scalar,~B.put_scalar)
def observed(~H:Type,~cap:Ops(H),capture:P.QueryPack,result:H & C.Access<U32>) -> H & (P.QueryPack & (T.Outcome<Unit> & U32)):
  match result:
    case (owner,C.Found{+value}):(Cap.set(~H,~U32,~U32,~cap,owner,(value+4:U32)),(P.update(value,capture),(T.Success{},value)))
    case (owner,_):(owner,(capture,(T.Failure{Unit{}},0)))
def body(~H:Type,~cap:Ops(H),capture:P.QueryPack,unit:Unit,owner:H) -> H & (P.QueryPack & (T.Outcome<Unit> & U32)):
  observed(~H,~cap,capture,Cap.get(~H,~U32,~U32,~cap,owner))
def Owned() -> Type:
  O.Owner<B.AuditWorkshop,B.Store,R.Resources(),Nat,P.QueryPack,Ops,Unit,Unit,U32,declaration(),body>
def define(world:B.World(R.Resources())) -> O.Registration<B.World(R.Resources()),Owned(),P.QueryPack>:
  O.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~P.QueryPack,~Ops,~Unit,~Unit,~U32,~declaration(),~body,world,"ScalarCaptured",P.QueryPack{ALeaf{0},ANode{ALeaf{30},ALeaf{40}}})
