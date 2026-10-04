import Base
import ./commands-bulk-controls.bend as B
import ./storage-stage-fixture.bend as F

def choose(schema: U32,count: U32) -> Bool:
  match schema:
    case 0: B.motion(count)
    case 1: B.health(count)
    case _: False{}
def bounded(schema: U32,count: U32,valid: Bool) -> IO(Unit):
  match valid:
    case True{}: IO.print(F.bool(choose(schema,count)))
    case False{}: IO.die(Unit,2,"count must be between 1 and 65537")
def parsed(schema: Maybe<&2,U32>,count: Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{+count}: bounded(schema,count,Bool.and(U32.is_gt(count,0),U32.is_le(count,65537)))
    case _ _: IO.die(Unit,2,"invalid arguments")
def args(values: List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
