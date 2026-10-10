import Base
import main.bend as Caller

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("A_initial|" ++ Caller.A_initial())
    IO.print("A_failed|" ++ Caller.A_failed())
    IO.print("A_retry|" ++ Caller.A_retry())
    IO.print("A_next|" ++ Caller.A_next())
    IO.print("A_condition_false|" ++ Caller.A_condition_false())
    IO.print("A_requirement_missing|" ++ Caller.A_requirement_missing())
    IO.print("A_missing_reader|" ++ Caller.A_missing_reader())
