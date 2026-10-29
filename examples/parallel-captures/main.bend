import Base
import ./report-probe.bend as Probe
import ./scheduled.bend as Independent
import ./guarded.bend as Guarded

def verified(valid:Bool) -> IO(Unit):
  match valid:
    case False{}:IO.print("ERROR:incomplete-report-observer")
    case True{}:IO.bind(String,Unit,Independent.run(~Independent.SchemaA,True{}),independentA => IO.bind(String,Unit,Independent.run(~Independent.SchemaB,True{}),independentB => IO.bind(String,Unit,Guarded.run(~Guarded.SchemaA,True{}),guardedA => IO.bind(String,Unit,Guarded.run(~Guarded.SchemaB,True{}),guardedB => IO.print("independent-A=" ++ independentA ++ "\nindependent-B=" ++ independentB ++ "\nguarded-A=" ++ guardedA ++ "\nguarded-B=" ++ guardedB)))))

def main() -> IO(Unit):verified(Probe.valid())
