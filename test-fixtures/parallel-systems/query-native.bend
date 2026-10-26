import Base
import ../../examples/parallel-query/commands-core.bend as Commands
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/execution-deferred-settings.bend as Settings

type Schema is Data:
  Schema{}
def main() -> IO(Unit):
  IO.print("root=serial/query=native=" ++ Commands.run_mode(~Schema,~Query.Parallel{},Settings.defaults(),False{}))
