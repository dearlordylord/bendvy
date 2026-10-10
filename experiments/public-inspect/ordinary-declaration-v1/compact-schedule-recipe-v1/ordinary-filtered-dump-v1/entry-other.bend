import Base
import ./consumer-public.bend as Consumer
type Other is Data:
  Other{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~Other,0n),Consumer.scenario(~Other,2n)}
