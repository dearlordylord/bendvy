import Base
import ./consumer.bend as Consumer
type Schema is Data:
  Schema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~Schema,0n),Consumer.scenario(~Schema,2n)}
