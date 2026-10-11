import Base
import ../state.bend as State
import fixture.bend as Fixture
import consumer.bend as Consumer
def main() -> Maybe<&2,Consumer.Report<State.Workshop>> & Maybe<&2,Consumer.Report<State.Garden>>:
  (Consumer.run(~State.Workshop,Fixture.world(~State.Workshop,31,100)),Consumer.run(~State.Garden,Fixture.world(~State.Garden,47,200)))
