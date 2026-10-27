import Base
import ./application.bend as Application
import ../../src/ecs/execution-query.bend as Query

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.bind(String,Unit,Application.run(~First,~Query.Serial{}),serial =>
    IO.bind(String,Unit,Application.run(~First,~Query.Parallel{}),parallel =>
      IO.bind(String,Unit,Application.run(~Second,~Query.Parallel{}),second =>
        IO.bind(String,Unit,Application.run_error(~First,~Query.Parallel{}),error =>
          IO.print("First/serial=" ++ serial ++ "\nFirst/parallel=" ++ parallel ++ "\nSecond/parallel=" ++ second ++ "\nFirst/error=" ++ error)))))
