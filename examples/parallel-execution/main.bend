import Base
import ./application.bend as Application

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,Application.run(~SchemaA),a => IO.bind(String,Unit,Application.run(~SchemaB),b => IO.print("A=" ++ a ++ "\nB=" ++ b)))
