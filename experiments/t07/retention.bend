import Base
import ./runtime.bend as R

def main() -> IO(Unit):
  IO.print(R.trace(R.run([
    R.Frame{}, R.EmitOp{[8], True{}}, R.Frame{}, R.Frame{}, R.Frame{}, R.ReadOp{False{}, True{}, "unregistered:late"}
  ], R.StepResult{R.initial(3n), ""})) ++ R.trace(R.run([
    R.Frame{}, R.ReadOp{False{}, True{}, "holder:init"},
    R.Frame{}, R.EmitOp{[7], True{}}, R.Frame{}, R.Frame{},
    R.Frame{}, R.ReadOp{True{}, True{}, "holder:new"}, R.ReadOp{False{}, True{}, "holder:first"}
  ], R.StepResult{R.initial(3n), ""})))
