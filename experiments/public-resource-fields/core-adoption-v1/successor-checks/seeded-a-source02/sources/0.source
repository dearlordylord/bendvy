import Base
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/resource-field-binding.bend as B
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/schema-b.bend as Other
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/consumer-engine.bend as Engine
def main() -> String:
  Engine.scenario(~Other.Other,~Other.Resources(),~Other.ReadOps,~Other.read_declaration(),~Other.read_body,~Other.resource_view,B.validate(~Other.Other,~Other.Resources(),~Other.Index(),Other.layout()),Other.initial())
