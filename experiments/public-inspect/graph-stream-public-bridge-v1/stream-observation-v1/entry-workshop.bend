import Base
import ../state.bend as State
import consumer.bend as Consumer
def main() -> Maybe<Consumer.Report<State.Workshop>>:
  Consumer.run(~State.Workshop,31,100)
