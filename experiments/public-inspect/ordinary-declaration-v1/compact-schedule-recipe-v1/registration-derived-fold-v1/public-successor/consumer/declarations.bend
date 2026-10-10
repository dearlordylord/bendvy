import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import ./fixture-full.bend as Full
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Stored
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/recipe-tree-v1/ordinary-unit.bend as Ordinary
def absent(~S:Data,unit:Unit) -> Presented.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  Fixture.absent_query(~S)
def first_query(~S:Data) -> O.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Fixture.read_ops(Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>),I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Projection.Product<C.Access<U32>,Unit>>:
  Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S))
def last_query(~S:Data) -> O.Declaration<S,Q.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit,I.Frame<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Unit>:
  Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~absent(~S))
def FirstRegistry(~S:Data) -> Type:
  Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S)),~Bodies.component)>
def FirstToken(~S:Data) -> Type:
  Stored.Token<FirstRegistry(~S)>
def First(~S:Data) -> Type:
  Leaf.Record<S,FirstToken(~S)>
def ResourceRegistry(~S:Data) -> Type:
  Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body)>
def ResourceToken(~S:Data) -> Type:
  Stored.Token<ResourceRegistry(~S)>
def Resource(~S:Data) -> Type:
  Leaf.Record<S,ResourceToken(~S)>
def LastRegistry(~S:Data) -> Type:
  Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~absent(~S)),~Fixture.absent_body)>
def LastToken(~S:Data) -> Type:
  Stored.Token<LastRegistry(~S)>
def Last(~S:Data) -> Type:
  Leaf.Record<S,LastToken(~S)>
def Owners(~S:Data) -> Type:
  ((Unit & First(~S)) & Resource(~S)) & Last(~S)
