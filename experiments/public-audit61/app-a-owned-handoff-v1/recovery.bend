import Base
import bundle.bend as B
import resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-component-capture.bend as Existing
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def identity() -> Identity.Declaration<B.AuditWorkshop,Array<U32>>:
  Identity.component(~B.AuditWorkshop,~Array<U32>,"array")
def binding() -> Binding.Binding<B.AuditWorkshop,B.Store,Col.Column<B.AuditWorkshop,U32>,Array<U32>,List<&2,U32>,B.ArrayToken,B.take_array,B.put_array,B.project_array>:
  Binding.bind(~B.AuditWorkshop,~B.Store,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,identity())
def Ops() -> Type -> Type:
  Component.Ops(~B.AuditWorkshop,~Array<U32>,~identity())
def Recovery() -> Type:
  List<RC.Record<B.AuditWorkshop,Array<U32>>>
def State() -> Type:
  Product.Owner<B.World(R.Resources()),Unit>
def declaration() -> D.Declaration<B.AuditWorkshop,State(),Recovery(),Ops(),Component.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~binding())>:
  Component.declaration(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~binding())
type Args is Type:
  Args{target:W.Handle<B.AuditWorkshop>,incoming:Array<U32>,fail:Bool}
def decision(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def attempted(~H:Type,fail:Bool,result:Existing.ComponentAttempt<H,Array<U32>>) -> H & (T.Outcome<Unit> & Maybe<&1,Array<U32>>):
  match result:
    case Existing.ComponentApplied{owner}:(owner,(decision(fail),None{}))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Unit{}},incoming))
def body(~H:Type,~cap:Ops()(H),args:Args,owner:H) -> H & (T.Outcome<Unit> & Maybe<&1,Array<U32>>):
  match args:
    case Args{target,incoming,fail}:attempted(~H,fail,Existing.component_replace(~B.AuditWorkshop,~Array<U32>,~identity(),~H,~cap,owner,target,Some{incoming}))
def Owned() -> Type:
  System.Owned(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Recovery(),~Ops(),~Args,~Unit,~Maybe<&1,Array<U32>>,~Component.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~binding()),~declaration(),~body)
def define(world:B.World(R.Resources())) -> System.Defined<B.World(R.Resources()),Owned(),Unit>:
  System.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Recovery(),~Ops(),~Args,~Unit,~Maybe<&1,Array<U32>>,~Component.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~binding()),~declaration(),~body,world,"ArrayRecovery",Unit{})
def run(owner:Owned(),world:B.World(R.Resources()),args:Args) -> System.Run<B.World(R.Resources()),Owned(),Args,Unit,Maybe<&1,Array<U32>>,Recovery()>:
  System.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Recovery(),~Ops(),~Args,~Unit,~Maybe<&1,Array<U32>>,~Component.grant(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~binding()),~declaration(),~body,owner,world,args)
def Run() -> Type:
  System.Run<B.World(R.Resources()),Owned(),Args,Unit,Maybe<&1,Array<U32>>,Recovery()>
