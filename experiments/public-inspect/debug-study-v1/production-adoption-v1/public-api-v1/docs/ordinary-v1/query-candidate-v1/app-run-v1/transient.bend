import Base
import ./scenario.bend as Scenario
import ./output.bend as Output

def main() -> Output.Outcome:
  Output.transient(Scenario.transient())
