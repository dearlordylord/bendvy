import Base
import ./core.bend as C

def main() -> IO(Unit):
  IO.print(C.trace(C.run([
    C.Frame{}, C.Queue{[C.Spawn{0, 1}, C.Spawn{1, 2}]}, C.Flush{},
    C.Frame{}, C.Queue{[C.Remove{0}, C.Despawn{1}]}, C.Flush{},
    C.Frame{}, C.Frame{}, C.Frame{}, C.ReadOp{False{}, True{}, "unheld:expired"}
  ], C.Output{C.initial(U32.to_nat(65536)), ""})))
