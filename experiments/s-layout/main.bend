import Base
import ./core.bend as B

def print_elapsed(start: Nat, result: String, end: Nat) -> IO(Unit):
  IO.print(result ++ ":" ++ Nat.show(Nat.sub(end, start)))
def stop(start: Nat, result: String) -> IO(Unit):
  do IO<Unit>:
    end : Nat <- IO.now()
    print_elapsed(start, result, end)
def timed(mode: U32, count: U32, w: B.World) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    stop(start, B.finish(B.loops(U32.to_nat(count), mode, 2, B.Outcome{w, 0})))
def execute(+mode: U32, +size: U32, count: U32) -> IO(Unit):
  timed(mode, count, B.setup(size, mode))
def warmup(+mode: U32, +size: U32, +count: U32) -> IO(Unit):
  IO.print("warm:" ++ B.finish(B.loops(U32.to_nat(count), mode, 2, B.Outcome{B.setup(size, mode), 0})))
def measured(+mode: U32, +size: U32, +count: U32) -> IO(Unit):
  do IO<Unit>:
    warmup(mode, size, count)
    warmup(mode, size, count)
    warmup(mode, size, count)
    execute(mode, size, count)
def parsed(mode: Maybe<&2, U32>, size: Maybe<&2, U32>, count: Maybe<&2, U32>) -> IO(Unit):
  match mode size count:
    case Some{mode} Some{size} Some{count}: measured(mode, size, count)
    case _ _ _: IO.die(Unit, 2, "invalid args")
def args(args: List<String>) -> IO(Unit):
  match args:
    case Con{_, Con{mode, Con{size, Con{count, _}}}}: parsed(U32.read(mode), U32.read(size), U32.read(count))
    case _: IO.die(Unit, 2, "mode size count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
