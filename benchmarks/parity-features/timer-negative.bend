import Base
import ./timing.bend as Bench
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Bench.capture("outside-region"),u => IO.bind(Unit,Unit,Bench.begin(),u => Bench.end()))
