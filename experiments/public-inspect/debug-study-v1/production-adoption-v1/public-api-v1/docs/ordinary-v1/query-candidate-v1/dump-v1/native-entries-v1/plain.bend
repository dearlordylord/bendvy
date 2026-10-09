import Base
import ../main.bend as Fixture
import ../../scenario-driver.bend as Driver

def main() -> Fixture.ReaderOutcome:
  Fixture.plain_delivered(Driver.plain())
