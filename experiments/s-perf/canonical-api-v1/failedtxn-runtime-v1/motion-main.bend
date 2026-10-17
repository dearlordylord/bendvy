import Base
import motion-driver.bend as Driver

def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>) -> IO(Unit):
  match count iterations:
    case Some{count} Some{iterations}:Driver.run(count,iterations)
    case _ _:IO.die(Unit,2,"count iterations must be U32")
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> count <> iterations <> _:parsed(U32.read(count),U32.read(iterations))
    case _:IO.die(Unit,2,"count iterations required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
