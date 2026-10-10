import Base
import ./consumer.bend as Consumer
type IndependentScheduledApplication is Data:
  IndependentScheduledApplication{}
def main() -> String:
  "Empty\n" ++ Consumer.scenario(~IndependentScheduledApplication,0n) ++ "Populated\n" ++ Consumer.scenario(~IndependentScheduledApplication,2n)
