import Base
import ../consumer/consumer.bend as Consumer
type ThirdApplicationSchema is Data:
  ThirdApplicationSchema{}
def main() -> String:
  Consumer.scenario(~ThirdApplicationSchema,2n)
