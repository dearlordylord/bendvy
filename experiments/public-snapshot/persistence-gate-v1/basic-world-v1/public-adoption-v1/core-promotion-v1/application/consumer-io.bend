import Base
import ./output.bend as Output
import ./supplement.bend as Supplement
# Full prior two-schema report AND every ordinary declaration/admission observation.
def main() -> IO(Unit):
  IO.print("{\"scenario\":" ++ Output.output() ++ ",\"ordinary\":" ++ Supplement.output() ++ "}")
