import Base
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D

def argument(unit:Unit) -> Unit:
  unit
def resource_observed(~H:Type,~caps:D.write_ops(~Array<U32>,~U32,H),result:H & U32) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,prior):(Cap.value_set(~H,~Array<U32>,~U32,~caps,owner,Array.new(U32,0n,U32.add(prior,1))),(T.Failure{Unit{}},Unit{}))
def resource(~H:Type,~caps:D.write_ops(~Array<U32>,~U32,H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  resource_observed(~H,~caps,Cap.value_get(~H,~Array<U32>,~U32,~caps,owner))

def component_checked(~H:Type,allowed:Bool,owner:H) -> H & (T.Outcome<Unit> & Unit):
  match allowed:
    case True{}:(owner,(T.Success{},Unit{}))
    case False{}:(owner,(T.Failure{Unit{}},Unit{}))
def component_read(~H:Type,result:H & C.Access<U32>) -> H & (T.Outcome<Unit> & Unit):
  match result:
    case (owner,C.Found{value}):component_checked(~H,U32.is_eq(value,42),owner)
    case (owner,_):component_checked(~H,False{},owner)
def component(~H:Type,~caps:Fixture.read_ops(H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  component_read(~H,Cap.read(~H,~U32,~Fixture.read_cap(~H,caps),owner))
