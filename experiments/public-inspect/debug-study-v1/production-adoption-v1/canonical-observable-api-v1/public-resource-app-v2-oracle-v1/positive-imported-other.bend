import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/consumer.bend as Consumer
type Independent is Data:
  Independent{}
def instantiate_empty() -> String:
  Consumer.scenario(~Independent,0n)
def instantiate_nonempty() -> String:
  Consumer.scenario(~Independent,2n)
