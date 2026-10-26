import Base
import ../parallel-query/application.bend as Application
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/lifecycle.bend as Life

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/added/serial=" ++ Application.run(~First,~Query.SerialWhere{Life.Added{}}) ++ "\nFirst/added/parallel=" ++ Application.run(~First,~Query.ParallelWhere{Life.Added{}}) ++ "\nSecond/changed/serial=" ++ Application.run(~Second,~Query.SerialWhere{Life.Changed{}}) ++ "\nSecond/changed/parallel=" ++ Application.run(~Second,~Query.ParallelWhere{Life.Changed{}}))
