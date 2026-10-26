import Base
import ./overlap.bend as Overlap
import ./scheduled.bend as Common

def main() -> IO(Unit):
  IO.print("A-serial=" ++ Overlap.run(~Common.SchemaA,False{}))
