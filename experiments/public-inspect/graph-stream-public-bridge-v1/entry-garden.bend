import Base
import fixture.bend as Fixture
import consumer.bend as Consumer
import state.bend as State
def main() -> Consumer.Report<State.Garden>:
  Consumer.run(~State.Garden,Fixture.world(~State.Garden,47,200))
