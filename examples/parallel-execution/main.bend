import Base
import ./application.bend as Application

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.print("A=" ++ Application.run(~SchemaA) ++ "\nB=" ++ Application.run(~SchemaB))
