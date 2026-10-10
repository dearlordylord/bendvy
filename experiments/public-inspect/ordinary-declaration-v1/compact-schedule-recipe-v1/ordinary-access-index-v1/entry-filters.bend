import Base
import ./consumer-filters.bend as Consumer
type ApplicationSchema is Data:
  ApplicationSchema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~ApplicationSchema,0n),Consumer.scenario(~ApplicationSchema,2n)}
