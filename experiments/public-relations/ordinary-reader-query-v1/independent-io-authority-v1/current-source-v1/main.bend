import Base
import ./consumer.bend as C
import ./render.bend as R
import ./fixture.bend as F

def workshop() -> IO(Unit):
  IO.bind(Maybe<C.Report<F.Workshop>>,Unit,C.run(~F.Workshop),value => R.completed(~F.Workshop,value))
def garden() -> IO(Unit):
  IO.bind(Maybe<C.Report<F.Garden>>,Unit,C.run(~F.Garden),value => R.completed(~F.Garden,value))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,workshop(),_ => garden())
