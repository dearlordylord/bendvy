import Base
import ./consumer-mutant.bend as Consumer

type Schema is Data:
  Schema{}
def main() -> String:
  Consumer.scenario(~Schema)
