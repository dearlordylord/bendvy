import Base
import ../state.bend as State
import fixture.bend as Fixture
import provenance.bend as Provenance
def main() -> Maybe<Provenance.Report<State.Garden>>:
  Provenance.run(~State.Garden,Fixture.world(~State.Garden,47,200))
