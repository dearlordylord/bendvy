import Base
import ./application.bend as Application
import ../../src/ecs/execution-parallel.bend as Parallel

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.print("A-serial=" ++ Application.run(~SchemaA,Parallel.Serial{}) ++ "\nA-native=" ++ Application.run(~SchemaA,Parallel.Native{}) ++ "\nB-serial=" ++ Application.run(~SchemaB,Parallel.Serial{}) ++ "\nB-native=" ++ Application.run(~SchemaB,Parallel.Native{}))
