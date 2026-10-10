import Base
import ./consumer.bend as Consumer
type IndependentScheduledApplication is Data:
  IndependentScheduledApplication{}
def main() -> Consumer.Report:
  Consumer.Report{Consumer.scenario(~IndependentScheduledApplication,0n),Consumer.scenario(~IndependentScheduledApplication,2n)}
