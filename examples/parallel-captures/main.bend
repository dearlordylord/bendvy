import Base
import ./report-probe.bend as Probe
import ./scheduled.bend as Independent
import ./guarded.bend as Guarded

def verified(valid:Bool) -> IO(Unit):
  match valid:
    case False{}:IO.print("ERROR:incomplete-report-observer")
    case True{}:IO.print("independent-A=" ++ Independent.run(~Independent.SchemaA,True{}) ++ "\nindependent-B=" ++ Independent.run(~Independent.SchemaB,True{}) ++ "\nguarded-A=" ++ Guarded.run(~Guarded.SchemaA,True{}) ++ "\nguarded-B=" ++ Guarded.run(~Guarded.SchemaB,True{}))

def main() -> IO(Unit):verified(Probe.valid())
