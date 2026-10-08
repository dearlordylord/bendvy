import Base
import fixture-output.bend as Output

# Complete two-schema192-query oracle consumer; no reduced functionality.
def main() -> IO(Unit):
  IO.print(Output.output())
