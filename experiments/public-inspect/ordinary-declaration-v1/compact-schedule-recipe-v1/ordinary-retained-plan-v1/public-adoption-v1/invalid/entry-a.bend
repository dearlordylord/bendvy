import Base
import ./consumer.bend as Consumer
type Workshop is Data:
  Workshop{}
def main() -> String:
  "Empty\n" ++ Consumer.scenario(~Workshop,0n) ++ "Populated\n" ++ Consumer.scenario(~Workshop,2n)
