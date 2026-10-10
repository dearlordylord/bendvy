import Base
import ./consumer.bend as Consumer
type Workshop is Data:
  Workshop{}
def main() -> String:
  Consumer.scenario(~Workshop,0n) ++ Consumer.scenario(~Workshop,2n)
