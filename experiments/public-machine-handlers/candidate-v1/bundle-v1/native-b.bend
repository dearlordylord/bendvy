import Base
import main.bend as Caller

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Caller.B_rows())
