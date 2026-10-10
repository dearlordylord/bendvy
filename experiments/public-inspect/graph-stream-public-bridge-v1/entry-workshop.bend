import Base
import fixture.bend as Fixture
import consumer.bend as Consumer
import state.bend as State
def main() -> Consumer.Report<State.Workshop>:
  Consumer.run(~State.Workshop,Fixture.world(~State.Workshop,31,100))
