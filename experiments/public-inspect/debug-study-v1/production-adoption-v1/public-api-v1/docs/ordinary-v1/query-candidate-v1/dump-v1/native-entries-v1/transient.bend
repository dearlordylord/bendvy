import Base
import ../main.bend as Fixture
import ../../scenario-driver.bend as Driver

def main() -> Fixture.ReaderOutcome:
  Fixture.transient_delivered(Driver.transient())
