import Base
import ./workshop/consumer.bend as Workshop
import ./garden/consumer.bend as Garden
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
def main() -> DTO.Product<Maybe<&2,Workshop.Report>,Maybe<&2,Garden.Report>>:
  DTO.Product{Workshop.run(),Garden.run()}
