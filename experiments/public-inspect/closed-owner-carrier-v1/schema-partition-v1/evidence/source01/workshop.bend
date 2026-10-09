import Base
import ../stage/output-adapter.bend as Output
import ../stage/five-phase-driver.bend as Driver
import ../stage/fixture.bend as Fixture
import ../stage/schema-families.bend as D

def main() -> IO(Unit):
  IO.write("schema|Workshop\n" ++ Output.driver(~D.Workshop,Driver.workshop()) ++ "retry|Workshop\n" ++ Output.retry(~D.Workshop,Fixture.workshop()))
