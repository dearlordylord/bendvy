import Base
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Selection
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/schema-families.bend as Families
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/execution.bend as Consumer

def bad(~S:Data,~Store:Type,~R:Type,~E:Data,value:Selection.Predicate<I.Frame<S,Store,R,E>,S>) -> Selection.Predicate<K.Frame<S,Store,R,E>,S>:
  value
def main() -> Unit:Unit{}
