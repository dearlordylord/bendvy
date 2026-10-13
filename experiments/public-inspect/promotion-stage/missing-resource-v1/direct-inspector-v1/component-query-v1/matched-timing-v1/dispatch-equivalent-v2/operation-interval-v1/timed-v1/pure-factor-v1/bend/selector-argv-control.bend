import Base
import repetition.bend as Repetition
def rendered(value:Maybe<&2,Repetition.Count>) -> String:
  match value:
    case None{}:"INVALID"
    case Some{Repetition.Count{count,intervals}}:Nat.show(count) ++ ":" ++ U32.show(intervals)
def invoked(values:List<String>) -> IO(String):IO.pure(String,rendered(Repetition.invoked(values)))
def main() -> IO(String):IO.bind(List<String>,String,IO.args(),invoked)
