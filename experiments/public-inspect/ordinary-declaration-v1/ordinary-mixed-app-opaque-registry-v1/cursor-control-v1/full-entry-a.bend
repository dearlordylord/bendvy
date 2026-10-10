import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/cursor-control-v1/full-consumer.bend as Consumer
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~Caller.A,0n),Consumer.scenario(~Caller.A,2n)}
