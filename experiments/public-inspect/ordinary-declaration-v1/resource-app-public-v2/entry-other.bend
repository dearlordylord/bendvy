import Base
import ./consumer.bend as Consumer
import ./fixture.bend as Fixture
type Other is Data:
  Other{}
type Report is Data:
  Report{empty:String,nonempty:String}
def main() -> Report:
  Report{Consumer.scenario(~Other,0n),Consumer.scenario(~Other,2n)}
