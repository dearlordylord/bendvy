import Base
import ../../../src/ecs/owned-event-log.bend as Log
import bundle.bend as B
import resources.bend as R
import capture.bend as P
import ../../../src/ecs/ordinary-resource-system.bend as Res
import ../../../src/ecs/ordinary-captures.bend as O
import ../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/transaction.bend as T
def projected(rest:Product.Owner<Array<U32>,R.Receipts>,result:Array<U32> & List<&2,U32>) -> R.User() & List<&2,U32>:
  (counter,values)=result
  (Product.Owner{counter,rest},values)
def project_user(resources:R.User()) -> R.User() & List<&2,U32>:
  match resources:
    case Product.Owner{counter,rest}:projected(rest,B.project_array(counter))
def project_join(log:Log.Log<Array<U32>>,result:R.User() & List<&2,U32>) -> R.Resources() & List<&2,U32>:
  (user,values)=result
  (Product.Owner{user,log},values)
def project(resources:R.Resources()) -> R.Resources() & List<&2,U32>:
  match resources:
    case Product.Owner{user,log}:project_join(log,project_user(user))
def Ops(H:Type) -> Type:
  Cap.ValueRead<H,List<&2,U32>>
def declaration() -> Res.Declaration<B.AuditWorkshop,R.Resources(),T.Tx<B.World(R.Resources()),Nat>,Ops(T.Tx<B.World(R.Resources()),Nat>)>:
  Res.read(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~List<&2,U32>,~project,Schema.resource(~B.AuditWorkshop,~R.Resources(),"WorkshopResources"))
def sum(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:(head + sum(tail) : U32)
def observed(~H:Type,capture:Array<U32>,result:H & List<&2,U32>) -> H & (Array<U32> & (T.Outcome<Unit> & Unit)):
  (owner,values)=result
  (owner,(P.increment((1 + sum(values) : U32),capture),(T.Success{},Unit{})))
def body(~H:Type,~cap:Ops(H),capture:Array<U32>,unit:Unit,owner:H) -> H & (Array<U32> & (T.Outcome<Unit> & Unit)):
  observed(~H,capture,Cap.value_read(~H,~List<&2,U32>,~cap,owner))
def runner() -> B.World(R.Resources()) -> Array<U32> -> Unit -> L.Outcome<B.World(R.Resources()),Array<U32>,Unit,Unit>:
  Ord.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Array<U32>,~Unit,~Unit,~Unit,~Ops,~declaration(),~body)
def Instance() -> Type:
  L.Instance<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Unit,Unit,runner()>
def define(world:B.World(R.Resources())) -> L.Registered<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Unit,Unit,runner()>:
  O.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Array<U32>,~Unit,~Unit,~Unit,~Ops,~declaration(),~body,world,"CounterCaptured",ANode{ALeaf{100},ALeaf{200}})
