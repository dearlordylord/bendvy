import Base
import ./consumer.bend as Consumer
import ./fixture.bend as Fixture
type Report is Data:
  Report{empty:String,nonempty:String}
def main() -> Report:
  Report{Consumer.scenario(~Fixture.A,0n),Consumer.scenario(~Fixture.A,2n)}
