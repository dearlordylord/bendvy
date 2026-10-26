import Base
import ./application.bend as Application
import ../../src/ecs/execution-query.bend as Query

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/serial=" ++ Application.run(~First,~Query.Serial{}) ++ "\nFirst/parallel=" ++ Application.run(~First,~Query.Parallel{}) ++ "\nSecond/parallel=" ++ Application.run(~Second,~Query.Parallel{}))
