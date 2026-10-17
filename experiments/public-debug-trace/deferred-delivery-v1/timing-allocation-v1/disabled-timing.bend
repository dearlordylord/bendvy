import Base
import ./host.bend as Host
import ../reader-query-context-v1/fixture.bend as F
import ../../../../benchmarks/parity-features/timing.bend as Timer
def ended(ignored:Unit) -> IO(Unit):Timer.end()
def captured(value:String) -> IO(Unit):IO.bind(Unit,Unit,Timer.capture("Workshop\n" ++ value),ended)
def started(ignored:Unit) -> IO(Unit):IO.bind(String,Unit,Host.run_mode(~F.Workshop,~False{}),captured)
def main() -> IO(Unit):IO.bind(Unit,Unit,Timer.begin(),started)
