import Base
import ./scheduled.bend as Independent
import ./guarded.bend as Guarded

def main() -> IO(Unit):
  IO.print("independent-A=" ++ Independent.run(~Independent.SchemaA,True{}) ++ "\nindependent-B=" ++ Independent.run(~Independent.SchemaB,True{}) ++ "\nguarded-A=" ++ Guarded.run(~Guarded.SchemaA,True{}) ++ "\nguarded-B=" ++ Guarded.run(~Guarded.SchemaB,True{}))
