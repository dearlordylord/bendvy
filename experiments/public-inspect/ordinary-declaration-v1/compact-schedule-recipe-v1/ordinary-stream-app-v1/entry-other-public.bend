import Base
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import consumer-public.bend as Consumer
def main() -> Maybe<Consumer.Report<State.Garden>>:
  Consumer.run(~State.Garden,47,200)
