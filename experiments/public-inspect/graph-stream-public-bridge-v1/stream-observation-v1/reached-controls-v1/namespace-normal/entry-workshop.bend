import Base
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import consumer.bend as Consumer
def main() -> Maybe<Consumer.Report<State.Workshop>>:
  Consumer.run(~State.Workshop,31,100)
