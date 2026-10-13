import Base
import ./timing.bend as Clock
import ./common-main.bend as Common

# One whole fresh 32-case lifecycle: workload and common report construction
# happen after begin; complete report capture happens before end; flush is after.
def captured(text:String) -> IO(Unit):
  IO.bind(Unit,Unit,Clock.capture(text),_ => IO.bind(Unit,Unit,Clock.end(),_ => Clock.finish(1)))
def begun() -> IO(Unit):
  IO.bind(Unit,Unit,Clock.begin(0),_ => captured(Common.main()))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Clock.reset(),_ => begun())
