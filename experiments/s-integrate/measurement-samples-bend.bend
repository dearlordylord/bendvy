# Timing driver: one warmup, then fresh worlds running the identical 64-step body.
import Base
import ./measurement-bend.bend as M

def samples(fuel:Nat,+schema:U32,+sparse:U32,+count:U32) -> IO(Unit):
  match fuel:
    case 0n: IO.pure(Unit,Unit{})
    case 1n+rest:
      do IO<Unit>:
        M.choose(schema,sparse,count)
        samples(rest,schema,sparse,count)
def run(+schema:U32,+sparse:U32,+count:U32,batch:U32) -> IO(Unit):
  do IO<Unit>:
    M.choose(schema,sparse,count)
    samples(U32.to_nat(batch),schema,sparse,count)
def parsed(schema:Maybe<&2,U32>,sparse:Maybe<&2,U32>,count:Maybe<&2,U32>,batch:Maybe<&2,U32>) -> IO(Unit):
  match schema sparse count batch:
    case Some{schema} Some{sparse} Some{count} Some{batch}: run(schema,sparse,count,batch)
    case _ _ _ _: IO.die(Unit,2,"schema sparse count batch required")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{sparse,Con{count,Con{batch,_}}}}}: parsed(U32.read(schema),U32.read(sparse),U32.read(count),U32.read(batch))
    case _: IO.die(Unit,2,"schema sparse count batch required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
