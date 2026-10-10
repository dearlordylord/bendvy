import Base
import fixture.bend as Fixture
import consumer.bend as Consumer
import state.bend as State
def main() -> Consumer.Report<State.Workshop> & Consumer.Report<State.Garden>:
  (Consumer.run(~State.Workshop,Fixture.world(~State.Workshop,31,100)),Consumer.run(~State.Garden,Fixture.world(~State.Garden,47,200)))
