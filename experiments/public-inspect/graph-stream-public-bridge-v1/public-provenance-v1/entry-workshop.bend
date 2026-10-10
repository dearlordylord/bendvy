import Base
import ../state.bend as State
import fixture.bend as Fixture
import provenance.bend as Provenance
def main() -> Maybe<Provenance.Report<State.Workshop>>:
  Provenance.run(~State.Workshop,Fixture.world(~State.Workshop,31,100))
