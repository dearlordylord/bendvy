import Base
import ../state.bend as State
import consumer.bend as Consumer
def main() -> Maybe<Consumer.Report<State.Garden>>:
  Consumer.run(~State.Garden,47,200)
