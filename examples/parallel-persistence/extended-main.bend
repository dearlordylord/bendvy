import Base
import ./extended-flow.bend as Flow
import ./extended-observation.bend as Observe
import ./extended-observation-data.bend as Data
import ./declarations.bend as O
import ../../src/ecs/execution-restore-extended-data.bend as Extended

def snapshot(~S:Data,value:Extended.Snapshot<S>) -> String:Data.snapshot(~S,value)
def observed(~S:Data,result:Flow.Outcome<S>) -> String:Observe.flow(~S,result)
def main() -> IO(Unit):IO.bind(Flow.Outcome<O.Alpha>,Unit,Flow.run(~O.Alpha),a => IO.bind(Unit,Unit,IO.print("alpha " ++ observed(~O.Alpha,a)),u => IO.bind(Flow.Outcome<O.Beta>,Unit,Flow.run(~O.Beta),b => IO.print("beta " ++ observed(~O.Beta,b)))))
