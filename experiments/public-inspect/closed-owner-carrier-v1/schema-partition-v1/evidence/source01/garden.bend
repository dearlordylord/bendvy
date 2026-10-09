import Base
import ../stage/output-adapter.bend as Output
import ../stage/five-phase-driver.bend as Driver
import ../stage/fixture.bend as Fixture
import ../stage/schema-families.bend as D

def main() -> IO(Unit):
  IO.print("schema|Garden\n" ++ Output.driver(~D.Garden,Driver.garden()) ++ "retry|Garden\n" ++ Output.retry(~D.Garden,Fixture.garden()))
