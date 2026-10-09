import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/retained-schema.bend as Schema
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-schema.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type ResourceSchema is Data:
  ResourceSchema{}
type Delivered is Type:
  Delivered{factory:W.Factory,world:W.World<ResourceSchema,Unit,Array<U32>,Unit>,app:App.Application<ResourceSchema,Unit,Array<U32>,Unit,Unit>,description:Maybe<&2,App.Description<ResourceSchema>>}
  BuildRejected{factory:W.Factory,world:W.World<ResourceSchema,Unit,Array<U32>,Unit>,owners:Unit}
  CreateRejected{factory:W.Factory,resource:Array<U32>}
def described(factory:W.Factory,world:W.World<ResourceSchema,Unit,Array<U32>,Unit>,got:App.Application<ResourceSchema,Unit,Array<U32>,Unit,Unit> & Maybe<&2,App.Description<ResourceSchema>>) -> Delivered:
  match got:
    case (app,description):Delivered{factory,world,app,description}
def built(factory:W.Factory,world:W.World<ResourceSchema,Unit,Array<U32>,Unit>,result:App.Built<ResourceSchema,Unit,Array<U32>,Unit,Unit>) -> Delivered:
  match result:
    case App.Invalid{owners}:BuildRejected{factory,world,owners}
    case App.Built{app}:described(factory,world,App.describe(~ResourceSchema,~Unit,~Array<U32>,~Unit,~Unit,app))
def created(result:W.Creation<ResourceSchema,Unit,Array<U32>,Unit>) -> Delivered:
  match result:
    case W.CreateRejected{factory,resource}:CreateRejected{factory,resource}
    case W.Created{factory,world}:
      schema=Ordinary.resource_schema(~ResourceSchema,~Array<U32>,Ordinary.resource(~ResourceSchema,~Array<U32>,"Settings"))
      built(factory,world,App.build(~ResourceSchema,~Unit,~Array<U32>,~Unit,~Unit,"Update",SP.Entry{Sch.Phase{"Update"},[]},App.empty(~ResourceSchema,~Unit,~Array<U32>,1,App.Enabled{},schema)))
def main() -> Delivered:
  created(W.create(~ResourceSchema,~Unit,~Array<U32>,~Unit,~(unit => unit),W.factory(),Array.new(U32,1n,17)))
