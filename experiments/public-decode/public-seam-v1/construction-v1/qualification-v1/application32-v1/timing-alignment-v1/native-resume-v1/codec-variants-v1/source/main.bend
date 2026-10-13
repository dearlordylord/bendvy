import Base
import ./cases.bend as Program
import ./format.bend as Format

def main() -> IO(Unit):
  IO.print(Format.output(Program.entries()))
