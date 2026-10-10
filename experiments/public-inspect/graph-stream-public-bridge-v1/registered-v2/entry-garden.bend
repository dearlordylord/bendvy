import Base
import ../state.bend as State
import ../fixture.bend as Fixture
import consumer.bend as Consumer
def main() -> Maybe<&2,Consumer.Report<State.Garden>>:
  Consumer.run(~State.Garden,Fixture.world(~State.Garden,47,200))
