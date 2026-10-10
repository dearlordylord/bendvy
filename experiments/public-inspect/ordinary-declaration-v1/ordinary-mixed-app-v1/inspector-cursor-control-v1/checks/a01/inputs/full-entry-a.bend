import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-v1/inspector-cursor-control-v1/full-consumer.bend as Consumer
import ../automatic-app-observation-v1/component.bend as Caller
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~Caller.A,0n),Consumer.scenario(~Caller.A,2n)}
