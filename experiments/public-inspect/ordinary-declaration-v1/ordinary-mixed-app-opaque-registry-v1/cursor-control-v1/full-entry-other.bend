import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/cursor-control-v1/full-consumer.bend as Consumer
type IndependentApplicationSchema is Data:
  IndependentApplicationSchema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~IndependentApplicationSchema,0n),Consumer.scenario(~IndependentApplicationSchema,2n)}
