import Base
import ../consumer.bend as Consumer
type IndependentApplicationSchema is Data:
  IndependentApplicationSchema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~IndependentApplicationSchema,0n),Consumer.scenario(~IndependentApplicationSchema,2n)}
