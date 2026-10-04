import Base
import ../t08/core.bend as C
import ./seams.bend as S

def main() -> IO(Unit):
  IO.print(S.trace(S.run([
    C.Frame{}, C.Queue{[C.Spawn{0, 1}, C.Spawn{1, 2}]}, C.ReadOp{False{}, True{}, "fast:pending"},
    C.Frame{}, C.Flush{}, C.ReadOp{False{}, True{}, "fast:spawn"},
    C.Frame{}, C.Write{11, True{}}, C.ReadOp{False{}, True{}, "fast:write"},
    C.Frame{}, C.ReadOp{True{}, True{}, "slow:late"},
    C.Frame{}, C.Queue{[C.Insert{0, 9}]}, C.ReadOp{False{}, True{}, "fast:insert-pending"}, C.Flush{}, C.ReadOp{False{}, True{}, "fast:overwrite"},
    C.Frame{}, C.Write{21, True{}}, C.EmitOp{6}, C.SkipOp{True{}},
    C.Frame{}, C.ReadOp{True{}, True{}, "slow:changed-after-skip"}, C.ReadOp{False{}, True{}, "fast:write-held"},
    C.Frame{}, C.Write{100, False{}},
    C.Frame{}, C.ReadOp{False{}, True{}, "fast:failed-write"},
    C.Frame{}, C.Write{31, True{}}, C.ReadOp{False{}, True{}, "fast:before-failed-reader"},
    C.Frame{}, C.ReadOp{True{}, False{}, "slow:failed"},
    C.Frame{}, C.ReadOp{True{}, True{}, "slow:retry"},
    C.Frame{}, C.Queue{[C.Remove{0}, C.Despawn{1}]}, C.ReadOp{False{}, True{}, "fast:cleanup-pending"},
    C.Frame{}, C.Flush{}, C.ReadOp{False{}, True{}, "fast:cleanup"},
    C.Frame{}, C.Frame{}, C.Frame{}, C.EmitOp{7}, C.SkipOp{True{}},
    C.Frame{}, C.ReadOp{True{}, False{}, "slow:after-skip-failed"},
    C.Frame{}, C.ReadOp{True{}, True{}, "slow:removal-retry"}, C.ReadOp{False{}, True{}, "fast:event-held"},
    C.Frame{}, C.Queue{[C.Insert{0, 5}]}, C.Flush{}, C.ReadOp{False{}, True{}, "fast:reinsert"},
    C.Frame{}, C.ReadOp{True{}, True{}, "slow:reinsert"},
    C.Frame{}, C.ReadOp{False{}, True{}, "fast:empty"}, C.ReadOp{True{}, True{}, "slow:empty"}
  ], S.Output{S.empty(2), ""})))
