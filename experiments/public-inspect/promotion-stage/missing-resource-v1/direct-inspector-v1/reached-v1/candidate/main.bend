import Base
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/consumer-source-v1/state.bend as State
import ./consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
def main() -> DTO.Product<List<&2,C.Report<State.Workshop>>,List<&2,C.Report<State.Garden>>>:
  DTO.Product{C.run(~State.Workshop),C.run(~State.Garden)}
