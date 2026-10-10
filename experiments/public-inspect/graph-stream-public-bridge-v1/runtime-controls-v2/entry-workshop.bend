import Base
import ../state.bend as State
import fixture.bend as Fixture
import consumer.bend as Consumer
def main() -> Consumer.Report<State.Workshop>:
  Consumer.run(~State.Workshop,Fixture.world(~State.Workshop,31,100))
