import Base
import ../consumer/consumer.bend as Consumer
type ThirdApplicationSchema is Data:
  ThirdApplicationSchema{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~ThirdApplicationSchema,0n),Consumer.scenario(~ThirdApplicationSchema,2n)}
