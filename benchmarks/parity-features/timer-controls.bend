import Base
import ./timing.bend as Bench
def captures() -> IO(Unit):
  IO.bind(Unit,Unit,Bench.capture(""),u => IO.bind(Unit,Unit,Bench.capture("λ🙂\nline"),u => IO.bind(Unit,Unit,Bench.capture(SCon{Chr{0},"tail"}),u => Bench.end())))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Bench.begin(),u => captures())
