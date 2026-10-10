import Base
import ../state.bend as State
import ../fixture.bend as Fixture
import foreign-handle.bend as Consumer
def main() -> Consumer.ForeignReport<State.Workshop>:
  Consumer.run(~State.Workshop,Fixture.world(~State.Workshop,31,100))
