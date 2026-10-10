import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import ../state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def retained(result:Consumer.Application(~Schema) & Maybe<&2,List<&2,W.Handle<Schema>>>) -> Consumer.Application(~Schema):
  match result:
    case (app,_):app
def forbidden(app:Consumer.Application(~Schema)) -> Consumer.Application(~Schema):
  retained(Relation.inverse_app(~Other,~State.Components<Other>,~State.Resources<Other>,~U32,~Consumer.declaration(~Other),~Unit,~Unit,~Build.empty_observe(~Consumer.World(~Other)),~Leaf.empty(~Other),app,W.Handle{1,2}))
def main() -> String:
  "source authority control"
