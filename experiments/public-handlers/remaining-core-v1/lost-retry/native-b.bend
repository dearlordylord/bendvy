import Base
import main.bend as Caller

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("B_initial|" ++ Caller.B_initial())
    IO.print("B_failed|" ++ Caller.B_failed())
    IO.print("B_retry|" ++ Caller.B_retry())
    IO.print("B_next|" ++ Caller.B_next())
    IO.print("B_condition_false|" ++ Caller.B_condition_false())
    IO.print("B_requirement_missing|" ++ Caller.B_requirement_missing())
    IO.print("B_missing_reader|" ++ Caller.B_missing_reader())
