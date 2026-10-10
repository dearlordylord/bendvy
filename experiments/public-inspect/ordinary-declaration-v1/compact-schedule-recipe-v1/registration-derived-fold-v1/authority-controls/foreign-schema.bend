import ../modules/ordinary-app-component.bend as ComponentRegistration
import ../modules/ordinary-app-resource.bend as ResourceRegistration
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ../modules/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import ../consumer/fixture-full.bend as Full
import ../modules/ordinary-app-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import Base
import ../consumer/dispatch.bend as Dispatch
import ../consumer/schedule-transport.bend as Transport
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import ../modules/ordinary-app-dispatch-result.bend as Results
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import ../consumer/declarations.bend as Decl
import ../modules/ordinary-app-records.bend as Leaf
import ../modules/ordinary-app-composer.bend as Build
import ../consumer/metadata.bend as Metadata
import ../modules/ordinary-app-recipe.bend as Tree
import ../modules/ordinary-app-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import ../consumer/frontend.bend as Auto
type AuthoritySchema is Data:
  AuthoritySchema{}
type OtherSchema is Data:
  OtherSchema{}
def register(world:W.World<AuthoritySchema,Col.Column<AuthoritySchema,Caller.Payload>,Array<U32>,U32>) -> Auto.Setup<AuthoritySchema>:
  ComponentRegistration.register(~AuthoritySchema,~Col.Column<AuthoritySchema,Caller.Payload>,~Array<U32>,~U32,~Unit,~Unit,~Build.empty_observe(~W.World<AuthoritySchema,Col.Column<AuthoritySchema,Caller.Payload>,Array<U32>,U32>),~Leaf.empty(~AuthoritySchema),~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Decl.first_query(~OtherSchema),~Auto.render_first,~Bodies.component,~Auto.Setup<AuthoritySchema>,Auto.first_appended(~AuthoritySchema),Auto.first_failed(~AuthoritySchema),Build.empty(~AuthoritySchema,~W.World<AuthoritySchema,Col.Column<AuthoritySchema,Caller.Payload>,Array<U32>,U32>,world),"PositionRead","Update")
