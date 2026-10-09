import Base
import ./scenario.bend as Scenario
import ./output.bend as Output

type Complete is Data:
  Complete{plain:Output.Outcome,transient:Output.Outcome,constructed:Output.Outcome}
def main() -> Complete:
  Complete{Output.plain(Scenario.plain()),Output.transient(Scenario.transient()),Output.constructed(Scenario.constructed())}
