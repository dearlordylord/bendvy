import Base
import ../parallel-query/application.bend as Application
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/lifecycle.bend as Life

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.bind(String,Unit,Application.run(~First,~Query.SerialWhere{Life.Added{}}),firstSerial => IO.bind(String,Unit,Application.run(~First,~Query.ParallelWhere{Life.Added{}}),firstParallel => IO.bind(String,Unit,Application.run(~Second,~Query.SerialWhere{Life.Changed{}}),secondSerial => IO.bind(String,Unit,Application.run(~Second,~Query.ParallelWhere{Life.Changed{}}),secondParallel => IO.print("First/added/serial=" ++ firstSerial ++ "\nFirst/added/parallel=" ++ firstParallel ++ "\nSecond/changed/serial=" ++ secondSerial ++ "\nSecond/changed/parallel=" ++ secondParallel)))))
