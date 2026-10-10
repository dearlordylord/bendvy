import Base
import ./consumer-public.bend as Consumer
type ApplicationSchema is Data:
  ApplicationSchema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~ApplicationSchema,0n),Consumer.scenario(~ApplicationSchema,2n)}
