import Base
import ./consumer-unrelate.bend as Consumer

type Schema is Data:
  Schema{}
def main() -> String:
  Consumer.scenario(~Schema)
