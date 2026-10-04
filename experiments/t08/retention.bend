import Base
import ./core.bend as C

def main() -> IO(Unit):
  IO.print(C.trace(C.run([
    C.Frame{}, C.Queue{[C.Spawn{0, 1}]}, C.Flush{}, C.ReadOp{False{}, True{}, "holder:init"},
    C.Frame{}, C.Write{9, True{}}, C.Frame{}, C.Frame{}, C.Frame{}, C.Frame{},
    C.ReadOp{True{}, True{}, "late:old-change"},
    C.Frame{}, C.Queue{[C.Despawn{0}]}, C.Flush{}, C.Frame{}, C.Frame{}, C.Frame{},
    C.ReadOp{False{}, True{}, "holder:old-removal"}, C.ReadOp{True{}, True{}, "late:old-removal"},
    C.Frame{}, C.Frame{}, C.ReadOp{False{}, True{}, "holder:empty"}
  ], C.Output{C.initial(U32.to_nat(65536)), ""})))
