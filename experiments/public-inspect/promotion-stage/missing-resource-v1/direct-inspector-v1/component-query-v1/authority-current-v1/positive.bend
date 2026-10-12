import Base
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Selection
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/schema-families.bend as Families
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/execution.bend as Consumer

def good(~H:Type,~S:Data,~V:Data,~grant:Q.ReadQuery<H,S,V>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,Q.LookupError,Selection.Row<S,V>>:
  Q.get(~H,~S,~V,~grant,owner,target)
def main() -> Unit:Unit{}
