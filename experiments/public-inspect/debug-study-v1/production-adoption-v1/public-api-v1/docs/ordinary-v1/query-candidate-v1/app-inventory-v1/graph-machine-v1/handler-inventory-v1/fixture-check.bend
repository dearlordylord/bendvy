import Base
import ./fixture.bend as Fixture
def consume(delivered:Fixture.Delivered) -> Unit:
  Unit{}
def main() -> Unit:
  consume(Fixture.main())
