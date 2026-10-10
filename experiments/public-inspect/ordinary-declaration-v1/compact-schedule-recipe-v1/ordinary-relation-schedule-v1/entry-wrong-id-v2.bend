import Base
import ./consumer-wrong-id-v2.bend as Consumer
type Schema is Data:
  Schema{}
def main() -> String:
  Consumer.scenario(~Schema)
