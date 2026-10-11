import Base
import state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as Resource

def ComponentOps(H:Type) -> Type:Cap.Read<H,U32>
def component_query() -> Query.Declaration<F.Other,Q.Frame<F.Other,F.Store,F.Resources,F.Events()>,ComponentOps(Q.Frame<F.Other,F.Store,F.Resources,F.Events()>),I.Frame<F.Other,F.Store,F.Resources,F.Events()>,Cmp.Access<U32>>:
  Query.read(~F.Other,~F.Store,~F.Rest,~Array<U32>,~U32,~F.First,~F.first_take,~F.first_put,~F.view,~F.Resources,~F.Events(),~F.first_binding())
def component_completed(~H:Type,result:H & Cmp.Access<U32>) -> H & (Tx.Outcome<Unit> & Unit):
  match result:
    case (owner,_):(owner,(Tx.Success{},Unit{}))
def component_body(~H:Type,~caps:ComponentOps(H),_:Unit,owner:H) -> H & (Tx.Outcome<Unit> & Unit):
  component_completed(~H,Cap.read(~H,~U32,~caps,owner))
def component_text(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.ComponentAbsent{}:"Absent"
    case Cmp.MissingEntity{}:"MissingEntity"
    case Cmp.Found{value}:"Present:" ++ U32.show(value)
def ResourceOps(H:Type) -> Type:Field.Read<F.Other,Array<U32>,F.inventory_identity(),H,U32>
def resource_declaration() -> Resource.Declaration<F.Other,F.Store,F.Resources,F.Events(),Resource.read_ops(~F.Other,~Array<U32>,~F.inventory_identity(),~U32),U32>:
  Resource.read(~F.Other,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.InventoryRest,~U32,~F.inventory_lens(),~F.inventory_identity(),~F.inventory_binding(),~F.view,~U32.show)
def resource_completed(~H:Type,result:H & U32) -> H & (Tx.Outcome<Unit> & Unit):
  match result:
    case (owner,_):(owner,(Tx.Success{},Unit{}))
def resource_body(~H:Type,~caps:ResourceOps(H),_:Unit,owner:H) -> H & (Tx.Outcome<Unit> & Unit):
  resource_completed(~H,Field.read_value(~F.Other,~Array<U32>,~F.inventory_identity(),~H,~U32,~caps,owner))
