import Base
import ./consumer.bend as Consumer
type IndependentApplicationSchema is Data:
  IndependentApplicationSchema{}
def main() -> String & String:
  (Consumer.scenario(~IndependentApplicationSchema,0n),Consumer.scenario(~IndependentApplicationSchema,2n))
