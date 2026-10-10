import Base
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/resource-field-binding.bend as B
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/schema-a.bend as A
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/consumer-engine.bend as Engine
def main() -> String:
  Engine.scenario(~A.A,~A.Resources(),~A.ReadOps,~A.read_declaration(),~A.read_body,~A.resource_view,B.validate(~A.A,~A.Resources(),~A.Index(),A.layout()),A.initial())
