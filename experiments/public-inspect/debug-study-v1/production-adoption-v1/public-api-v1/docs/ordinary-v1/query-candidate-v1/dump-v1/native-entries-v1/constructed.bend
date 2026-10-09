import Base
import ../main.bend as Fixture
import ../../scenario-driver.bend as Driver

def main() -> Fixture.ReaderOutcome:
  Fixture.constructed_delivered(Driver.constructed())
