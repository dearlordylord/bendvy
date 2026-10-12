import Base
import ./state.bend as State
import ./consumer.bend as Consumer
def main() -> List<&2,String> & List<&2,String>:
  (Consumer.run(~State.Workshop),Consumer.run(~State.Garden))
