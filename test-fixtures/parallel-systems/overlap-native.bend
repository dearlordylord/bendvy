import Base
import ./overlap.bend as Overlap
import ./scheduled.bend as Common

def main() -> IO(Unit):
  IO.print("A-native=" ++ Overlap.run(~Common.SchemaA,True{}))
