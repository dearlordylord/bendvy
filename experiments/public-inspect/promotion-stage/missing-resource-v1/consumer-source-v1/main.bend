import Base
import ./state.bend as State
import ./consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
def main() -> DTO.Product<List<&2,C.Report<State.Workshop>>,List<&2,C.Report<State.Garden>>>:
  DTO.Product{C.run(~State.Workshop),C.run(~State.Garden)}
