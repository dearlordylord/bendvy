import Base
import output-adapter.bend as Output
import five-phase-driver.bend as Driver
import fixture.bend as Fixture
import schema-families.bend as D

def workshop_driver() -> IO(Unit):
  IO.write("schema|Workshop\n" ++ Output.driver(~D.Workshop,Driver.workshop()))
def workshop_retry() -> IO(Unit):
  IO.write("retry|Workshop\n" ++ Output.retry(~D.Workshop,Fixture.workshop()))
def garden_driver() -> IO(Unit):
  IO.write("schema|Garden\n" ++ Output.driver(~D.Garden,Driver.garden()))
def garden_retry() -> IO(Unit):
  IO.print("retry|Garden\n" ++ Output.retry(~D.Garden,Fixture.garden()))
def after_garden_driver(value:Unit) -> IO(Unit):
  garden_retry()
def after_workshop_retry(value:Unit) -> IO(Unit):
  IO.bind(Unit,Unit,garden_driver(),after_garden_driver)
def after_workshop_driver(value:Unit) -> IO(Unit):
  IO.bind(Unit,Unit,workshop_retry(),after_workshop_retry)
def main() -> IO(Unit):
  IO.bind(Unit,Unit,workshop_driver(),after_workshop_driver)
