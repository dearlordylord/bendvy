import Base
import ./runtime.bend as R

def main() -> IO(Unit):
  IO.print(R.trace(R.run([
    R.Frame{}, R.ReadOp{False{}, True{}, "fast:init"},
    R.Frame{}, R.ReadOp{True{}, True{}, "slow:init"},
    R.Frame{}, R.EmitOp{[1, 2], True{}}, R.ReadOp{False{}, True{}, "fast:batch12"},
    R.Frame{}, R.EmitOp{[3], True{}}, R.ReadOp{False{}, True{}, "fast:batch3"},
    R.Frame{}, R.ReadOp{False{}, True{}, "fast:empty"}, R.ReadOp{True{}, False{}, "slow:failed"},
    R.Frame{}, R.ReadOp{True{}, True{}, "slow:retry"},
    R.Frame{}, R.ReadOp{False{}, True{}, "fast:again"}, R.ReadOp{True{}, True{}, "slow:again"},
    R.Frame{}, R.EmitOp{[9], False{}}, R.ReadOp{True{}, True{}, "slow:failed-emission"},
    R.Frame{}, R.EmitOp{[4], True{}}, R.SkipOp{True{}},
    R.Frame{}, R.ReadOp{True{}, True{}, "slow:after-skip"}, R.ReadOp{False{}, True{}, "fast:held"}
  ], R.StepResult{R.initial(U32.to_nat(65536)), ""})))
